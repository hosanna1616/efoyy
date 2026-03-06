import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/models/queue_entry.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

final queueProvider = StreamProvider.family<List<QueueEntry>, String>((ref, room) async* {
  // First yield empty list immediately for better UX
  yield <QueueEntry>[];
  
  try {
    // Try Supabase stream first
    yield* SupabaseService.watchQueue(room).handleError((error) {
      print('Queue stream error: $error');
      // Fallback to offline
      return Stream.value(<QueueEntry>[]);
    });
  } catch (e) {
    print('Queue stream error, using offline data: $e');
    // Fallback to offline Hive data
    final offlineEntries = HiveService.getAllQueueEntries()
        .where((entry) => entry.room == room && entry.isActive)
        .toList()
      ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
    yield offlineEntries;
    
    // Keep checking for updates periodically
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      try {
        // Try to reconnect to Supabase
        yield* SupabaseService.watchQueue(room);
        break; // If successful, use Supabase stream
      } catch (_) {
        // Still offline, yield local data
        final updated = HiveService.getAllQueueEntries()
            .where((entry) => entry.room == room && entry.isActive)
            .toList()
          ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
        yield updated;
      }
    }
  }
});

final currentQueueEntryProvider = StateNotifierProvider<CurrentQueueEntryNotifier, QueueEntry?>((ref) {
  return CurrentQueueEntryNotifier();
});

class CurrentQueueEntryNotifier extends StateNotifier<QueueEntry?> {
  Timer? _updateTimer;
  Timer? _positionUpdateTimer;
  int? _lastNotifiedPosition;
  
  CurrentQueueEntryNotifier() : super(null) {
    _loadExistingQueueEntry();
  }
  
  Future<void> _loadExistingQueueEntry() async {
    // Load active queue entry from Hive for current patient
    try {
      // Get current patient ID from settings
      final settingsBox = Hive.box('settings');
      final currentPatientId = settingsBox.get('current_patient_id') as String?;
      
      if (currentPatientId == null) {
        state = null;
        return;
      }
      
      final allEntries = HiveService.getAllQueueEntries();
      // Filter by current patient ID to ensure we only load their queue entry
      final patientEntries = allEntries
          .where((e) => e.isActive && e.patientId == currentPatientId)
          .toList();
      
      final activeEntry = patientEntries.isNotEmpty ? patientEntries.first : null;
      
      if (activeEntry != null) {
        state = activeEntry;
        // Start monitoring position updates
        _startPositionMonitoring(activeEntry);
        // Start SMS updates
        _startSMSUpdates(activeEntry);
      } else {
        state = null;
      }
    } catch (e) {
      print('Error loading existing queue entry: $e');
      state = null;
    }
  }
  
  void _startPositionMonitoring(QueueEntry entry) {
    _positionUpdateTimer?.cancel();
    // Update position every 5 seconds
    _positionUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (state == null || !state!.isActive) {
        timer.cancel();
        return;
      }
      
      await _updateQueuePosition();
      
      // Check if it's patient's turn (position 0)
      if (state != null && state!.currentPosition == 0 && state!.calledAt == null) {
        // Patient's turn! Send urgent SMS
        try {
          await SMSService.sendSMS(
            phoneNumber: state!.patientPhone,
            message: 'ተራዎ ነው! ወደ ${state!.room} ይሂዱ - Your turn! Go to ${state!.room}',
          );
        } catch (e) {
          print('Error sending turn notification SMS: $e');
          // Continue even if SMS fails
        }
        
        // Mark as notified to prevent duplicate SMS
        _lastNotifiedPosition = 0;
        
        // Show notification (for smartphone users)
        // This will be handled by the UI layer
      }
    });
  }
  
  Future<void> joinQueue({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String room,
  }) async {
    try {
      // Always allow join - SupabaseService will handle duplicate check
      // This allows multiple different patients to join the same queue
      final entry = QueueEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        queueNumber: 0, // Will be set by SupabaseService
        room: room,
        joinedAt: DateTime.now(),
        isActive: true,
      );
      
      final created = await SupabaseService.joinQueue(entry);
      
      // The created entry already has correct position from SupabaseService
      // But let's verify by getting the current queue
      final queue = await SupabaseService.getQueue(room);
      final position = queue.indexWhere((e) => e.id == created.id);
      
      // Use the position from the queue if available, otherwise use created entry
      final updated = position >= 0 
          ? queue[position] // Use entry from queue which has correct position
          : created.copyWith(
              currentPosition: position >= 0 ? position : queue.length - 1,
              totalInQueue: queue.length,
            );
      
      // Ensure the updated entry has correct position (1-based for display)
      final finalEntry = updated.copyWith(
        currentPosition: position >= 0 ? position : updated.currentPosition,
        totalInQueue: queue.length,
      );
      
      await HiveService.saveQueueEntry(finalEntry);
      state = finalEntry;
      
      // Start monitoring position updates
      _startPositionMonitoring(updated);
      
      // Start periodic SMS updates for button phones
      _startSMSUpdates(updated);
      
      // Send initial SMS
      await SMSService.sendQueueUpdate(
        phoneNumber: patientPhone,
        queueNumber: updated.queueNumber,
        position: updated.currentPosition,
        totalInQueue: updated.totalInQueue,
        room: room,
      );
    } catch (e) {
      print('Error joining queue: $e');
      // Create offline entry
      final offlineEntry = QueueEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        queueNumber: 1,
        room: room,
        joinedAt: DateTime.now(),
        isActive: true,
      );
      await HiveService.saveQueueEntry(offlineEntry);
      state = offlineEntry;
    }
  }
  
  void _startSMSUpdates(QueueEntry entry) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      if (state == null || !state!.isActive) {
        timer.cancel();
        return;
      }
      
      // Update position from queue
      await _updateQueuePosition();
      
      if (state != null) {
        await SMSService.sendQueueUpdate(
          phoneNumber: state!.patientPhone,
          queueNumber: state!.queueNumber,
          position: state!.currentPosition,
          totalInQueue: state!.totalInQueue,
          room: state!.room,
        );
      }
    });
  }
  
  Future<void> _updateQueuePosition() async {
    if (state == null) return;
    
    try {
      // Use getQueue instead of watchQueue for more reliable updates
      final queue = await SupabaseService.getQueue(state!.room);
      final position = queue.indexWhere((e) => e.id == state!.id);
      
      if (position >= 0) {
        final queueEntry = queue[position];
        final previousPosition = state!.currentPosition;
        final updated = queueEntry.copyWith(
          currentPosition: position,
          totalInQueue: queue.length,
        );
        
        state = updated;
        await HiveService.saveQueueEntry(updated);
        
        // If position improved (moved forward), send update SMS
        if (position < previousPosition && position > 0) {
          await SMSService.sendQueueUpdate(
            phoneNumber: updated.patientPhone,
            queueNumber: updated.queueNumber,
            position: updated.currentPosition,
            totalInQueue: updated.totalInQueue,
            room: updated.room,
          );
        }
      } else {
        // Entry not found in queue - might have been removed
        if (state!.isActive) {
          state = state!.copyWith(isActive: false);
          await HiveService.saveQueueEntry(state!);
        }
      }
    } catch (e) {
      print('Error updating queue position: $e');
      // Fallback to Hive data
      try {
        final queue = HiveService.getAllQueueEntries()
            .where((e) => e.room == state!.room && e.isActive)
            .toList()
          ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
        final position = queue.indexWhere((e) => e.id == state!.id);
        if (position >= 0) {
          state = state!.copyWith(
            currentPosition: position,
            totalInQueue: queue.length,
          );
        }
      } catch (_) {
        // Ignore
      }
    }
  }
  
  Future<void> callNext(String room) async {
    try {
      // Get first in queue before calling
      final queue = await SupabaseService.getQueue(room);
      if (queue.isNotEmpty) {
        final current = queue.first;
        
        // Mark as called in Supabase
        await SupabaseService.callNext(room);
        
        // Update local state if this is the current patient
        if (state != null && state!.id == current.id) {
          state = state!.copyWith(
            calledAt: DateTime.now(),
            isActive: false,
          );
          await HiveService.saveQueueEntry(state!);
        }
        
        // Get updated queue to find next person
        final updatedQueue = await SupabaseService.getQueue(room);
        if (updatedQueue.isNotEmpty) {
          final nextPerson = updatedQueue.first;
          
          // Send urgent SMS to next patient
          try {
            await SMSService.sendSMS(
              phoneNumber: nextPerson.patientPhone,
              message: 'ተራዎ ነው! ወደ $room ይሂዱ - Your turn! Go to $room',
            );
          } catch (e) {
            print('Error sending SMS to next person: $e');
            // Continue even if SMS fails
          }
        }
        
        // Update positions for remaining patients
        // The queue stream will automatically update
      }
    } catch (e) {
      print('Error calling next: $e');
      rethrow;
    }
  }

  Future<void> deleteFromQueue(String entryId, String room) async {
    try {
      // Get the entry before deleting
      final queue = await SupabaseService.getQueue(room);
      final entryToDelete = queue.firstWhere((e) => e.id == entryId, orElse: () => queue.first);
      
      // Delete from Supabase
      await SupabaseService.deleteFromQueue(entryId);
      
      // Update local state if this is the current patient
      if (state != null && state!.id == entryId) {
        state = state!.copyWith(
          calledAt: DateTime.now(),
          isActive: false,
        );
        await HiveService.saveQueueEntry(state!);
      }
      
      // Get updated queue to find next person
      final updatedQueue = await SupabaseService.getQueue(room);
      if (updatedQueue.isNotEmpty) {
        final nextPerson = updatedQueue.first;
        
        // Send urgent SMS to next patient
        try {
          await SMSService.sendSMS(
            phoneNumber: nextPerson.patientPhone,
            message: 'ተራዎ ነው! ወደ $room ይሂዱ - Your turn! Go to $room',
          );
        } catch (e) {
          print('Error sending SMS to next person: $e');
          // Continue even if SMS fails
        }
      }
    } catch (e) {
      print('Error deleting from queue: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }
}

