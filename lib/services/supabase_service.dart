import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:efoy/models/patient.dart';
import 'package:efoy/models/queue_entry.dart';
import 'package:efoy/models/instruction.dart';
import 'package:efoy/models/navigation_step.dart';
import 'package:efoy/models/pain_report.dart';
import 'package:efoy/models/feedback.dart' as efoy;
import 'package:efoy/services/config_service.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isOfflineMode = false;
  
  static bool get isOfflineMode => _isOfflineMode;
  
  static Future<void> init() async {
    try {
      // Get configuration from ConfigService
      final supabaseUrl = await ConfigService.getSupabaseUrl();
      final supabaseAnonKey = await ConfigService.getSupabaseAnonKey();
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        // For development, don't initialize Supabase (will work offline)
        _isOfflineMode = true;
        print('⚠️ Supabase not configured - running in offline mode');
        print('💡 Configure in Settings or set SUPABASE_URL and SUPABASE_ANON_KEY environment variables');
        // Don't initialize Supabase in offline mode to avoid connection errors
        return;
      } else {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        _client = Supabase.instance.client;
        _isOfflineMode = false;
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      print('⚠️ Supabase initialization error (will use offline mode): $e');
      _isOfflineMode = true;
    }
  }
  
  static SupabaseClient? get client {
    if (_isOfflineMode || _client == null) {
      return null;
    }
    return _client;
  }
  
  static bool _shouldSkipError() {
    return _isOfflineMode;
  }
  
  // Patient Operations
  static Future<Patient?> getPatientByPhone(String phone) async {
    if (_isOfflineMode || _client == null) {
      return null; // Will use Hive offline
    }
    try {
      final response = await _client!
          .from('patients')
          .select()
          .eq('phone_number', phone)
          .maybeSingle();
      
      if (response == null) return null;
      return Patient.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting patient: $e');
      }
      return null;
    }
  }
  
  static Future<Patient> createPatient(Patient patient) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create patient in Supabase');
    }
    try {
      final response = await _client!
          .from('patients')
          .insert(patient.toJson())
          .select()
          .single();
      
      return Patient.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating patient: $e');
      }
      rethrow;
    }
  }
  
  static Future<Patient> updatePatient(Patient patient) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot update patient in Supabase');
    }
    try {
      final response = await _client!
          .from('patients')
          .update(patient.toJson())
          .eq('id', patient.id)
          .select()
          .single();
      
      return Patient.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error updating patient: $e');
      }
      rethrow;
    }
  }
  
  // Queue Operations
  static Stream<List<QueueEntry>> watchQueue(String room) {
    if (_isOfflineMode || _client == null) {
      // Return empty stream in offline mode
      return Stream.value(<QueueEntry>[]);
    }
    try {
      return _client!
          .from('queue_entries')
          .stream(primaryKey: ['id'])
          .order('queue_number')
          .map((data) {
            // Filter in memory for now (Supabase stream filters may not work as expected)
            final filtered = data.where((json) {
              return json['room'] == room && json['is_active'] == true;
            }).toList();
            final entries = filtered.map((json) {
              try {
                return QueueEntry.fromJson(json);
              } catch (e) {
                print('Error parsing queue entry: $e');
                return null;
              }
            }).whereType<QueueEntry>().toList();
            
            // Sort by queue_number (first come first serve)
            entries.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
            
            // Calculate positions based on sorted order (0-based for internal use)
            // Display will show position + 1 (1-based for users)
            final total = entries.length;
            for (int i = 0; i < entries.length; i++) {
              entries[i] = entries[i].copyWith(
                currentPosition: i, // 0-based: first person is 0, second is 1, etc.
                totalInQueue: total,
              );
            }
            
            return entries;
          });
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating queue stream: $e');
      }
      // Return empty stream if Supabase fails
      return Stream.value(<QueueEntry>[]);
    }
  }
  
  static Future<List<QueueEntry>> getQueue(String room) async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('queue_entries')
          .select()
          .eq('room', room)
          .eq('is_active', true)
          .order('queue_number');
      
      final entries = (response as List)
          .map((json) => QueueEntry.fromJson(json))
          .toList();
      
      // Sort by queue_number to ensure correct order (first come first serve)
      entries.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
      
      // Calculate positions based on sorted order (1-based position for display)
      final total = entries.length;
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(
          currentPosition: i, // 0-based for internal use, will be +1 for display
          totalInQueue: total,
        );
      }
      
      return entries;
    } catch (e) {
      print('Error getting queue: $e');
      return [];
    }
  }
  
  static Future<QueueEntry> joinQueue(QueueEntry entry) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot join queue in Supabase');
    }
    try {
      // Check if patient is already in queue for this room
      final existingEntry = await _client!
          .from('queue_entries')
          .select()
          .eq('patient_id', entry.patientId)
          .eq('room', entry.room)
          .eq('is_active', true)
          .maybeSingle();
      
      if (existingEntry != null) {
        // Patient already in queue, return existing entry
        final existing = QueueEntry.fromJson(existingEntry);
        final queue = await getQueue(entry.room);
        final position = queue.indexWhere((e) => e.id == existing.id);
        if (position >= 0 && position < queue.length) {
          return queue[position];
        }
        return existing;
      }
      
      // Get the maximum queue_number from ALL entries (including inactive) for this room
      // This ensures queue numbers are sequential even after restarts
      final allEntriesResponse = await _client!
          .from('queue_entries')
          .select('queue_number')
          .eq('room', entry.room)
          .order('queue_number', ascending: false)
          .limit(1)
          .maybeSingle();
      
      int queueNumber = 1;
      if (allEntriesResponse != null && allEntriesResponse['queue_number'] != null) {
        final maxNumber = allEntriesResponse['queue_number'] as int;
        queueNumber = maxNumber + 1;
      }
      
      // Also check active entries to ensure we're using the highest active number
      // This handles the case where inactive entries might have higher numbers
      final activeEntriesResponse = await _client!
          .from('queue_entries')
          .select('queue_number')
          .eq('room', entry.room)
          .eq('is_active', true)
          .order('queue_number', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (activeEntriesResponse != null && activeEntriesResponse['queue_number'] != null) {
        final maxActive = activeEntriesResponse['queue_number'] as int;
        // Use the higher of the two to ensure sequential numbering
        if (maxActive >= queueNumber) {
          queueNumber = maxActive + 1;
        }
      }
      
      // Final check: Get count of active entries to handle race conditions
      // If we have N active entries, the next number should be at least N+1
      final activeList = await _client!
          .from('queue_entries')
          .select('id')
          .eq('room', entry.room)
          .eq('is_active', true);
      
      final activeCount = (activeList as List).length;
      // Ensure queue number is at least one more than the count
      // This handles concurrent joins where multiple users join at the same time
      if (activeCount + 1 > queueNumber) {
        queueNumber = activeCount + 1;
      }
      
      final entryWithNumber = entry.copyWith(queueNumber: queueNumber);
      
      // Insert the new queue entry
      final response = await _client!
          .from('queue_entries')
          .insert(entryWithNumber.toJson())
          .select()
          .single();
      
      final created = QueueEntry.fromJson(response);
      
      // Wait a brief moment to ensure database trigger has processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Get updated queue to calculate position (already sorted and positions calculated)
      final updatedQueue = await getQueue(entry.room);
      final position = updatedQueue.indexWhere((e) => e.id == created.id);
      
      // Return entry with correct position from the updated queue
      if (position >= 0 && position < updatedQueue.length) {
        // Use the entry from queue which has correct position and queue_number
        return updatedQueue[position];
      }
      
      // Fallback if not found in queue (shouldn't happen, but handle gracefully)
      return created.copyWith(
        currentPosition: position >= 0 ? position : updatedQueue.length,
        totalInQueue: updatedQueue.length,
      );
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error joining queue: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> callNext(String room) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot call next in Supabase');
    }
    try {
      // Get first in queue
      final firstInQueue = await _client!
          .from('queue_entries')
          .select()
          .eq('room', room)
          .eq('is_active', true)
          .order('queue_number')
          .limit(1)
          .maybeSingle();
      
      if (firstInQueue != null) {
        // Mark as called but keep active (nurse will remove manually)
        await _client!
            .from('queue_entries')
            .update({
              'called_at': DateTime.now().toIso8601String(),
              // Keep is_active = true so entry stays in queue until nurse removes it
            })
            .eq('id', firstInQueue['id']);
        
        // Get next person in queue to notify
        final nextInQueue = await _client!
            .from('queue_entries')
            .select()
            .eq('room', room)
            .eq('is_active', true)
            .order('queue_number')
            .limit(1)
            .maybeSingle();
        
        // Next person will be notified automatically via the queue stream
        // and SMS will be sent by the queue provider
        return;
      }
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error calling next: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteFromQueue(String entryId) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot delete from queue in Supabase');
    }
    try {
      // Get the entry before deleting to notify next person
      final entry = await _client!
          .from('queue_entries')
          .select()
          .eq('id', entryId)
          .maybeSingle();
      
      if (entry != null) {
        final room = entry['room'] as String;
        
        // Delete the entry (set is_active to false) - only when nurse manually removes
        await _client!
            .from('queue_entries')
            .update({
              'is_active': false,
              'called_at': DateTime.now().toIso8601String(),
            })
            .eq('id', entryId);
        
        // Get next person in queue to notify
        final nextInQueue = await _client!
            .from('queue_entries')
            .select()
            .eq('room', room)
            .eq('is_active', true)
            .order('queue_number')
            .limit(1)
            .maybeSingle();
        
        // Next person will be notified automatically via the queue stream
        return;
      }
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error deleting from queue: $e');
      }
      rethrow;
    }
  }

  static Future<void> removeFromQueue(String entryId) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot remove from queue in Supabase');
    }
    try {
      await _client!
          .from('queue_entries')
          .update({'is_active': false})
          .eq('id', entryId);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error removing from queue: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateQueuePosition(String entryId, int newPosition) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot update queue position in Supabase');
    }
    try {
      // Get current queue for the room
      final entry = await _client!
          .from('queue_entries')
          .select('room')
          .eq('id', entryId)
          .single();
      
      final room = entry['room'] as String;
      
      // Get all active entries for this room
      final allEntries = await _client!
          .from('queue_entries')
          .select()
          .eq('room', room)
          .eq('is_active', true)
          .order('queue_number');
      
      // Reorder queue
      final entries = (allEntries as List).cast<Map<String, dynamic>>();
      entries.removeWhere((e) => e['id'] == entryId);
      
      // Insert at new position
      if (newPosition < entries.length) {
        entries.insert(newPosition, {'id': entryId});
      } else {
        entries.add({'id': entryId});
      }
      
      // Update queue numbers
      for (int i = 0; i < entries.length; i++) {
        await _client!
            .from('queue_entries')
            .update({'queue_number': i + 1})
            .eq('id', entries[i]['id']);
      }
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error updating queue position: $e');
      }
      rethrow;
    }
  }
  
  // Instruction Operations
  static Future<Instruction> createInstruction(Instruction instruction) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create instruction in Supabase');
    }
    try {
      final response = await _client!
          .from('instructions')
          .insert(instruction.toJson())
          .select()
          .single();
      
      return Instruction.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating instruction: $e');
      }
      rethrow;
    }
  }
  
  static Future<List<Instruction>> getPatientInstructions(String patientId) async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('instructions')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Instruction.fromJson(json))
          .toList();
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting instructions: $e');
      }
      return [];
    }
  }

  static Stream<List<Instruction>> watchPatientInstructions(String patientId) {
    if (_isOfflineMode || _client == null) {
      return Stream.value(<Instruction>[]);
    }
    try {
      return _client!
          .from('instructions')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) {
            final filtered = data.where((json) {
              return json['patient_id'] == patientId;
            }).toList();
            return filtered.map((json) {
              try {
                return Instruction.fromJson(json);
              } catch (e) {
                print('Error parsing instruction: $e');
                return null;
              }
            }).whereType<Instruction>().toList();
          });
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating instructions stream: $e');
      }
      return Stream.value(<Instruction>[]);
    }
  }
  
  // Navigation Operations
  static Future<NavigationStep> createNavigationStep(NavigationStep step) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create navigation step in Supabase');
    }
    try {
      final response = await _client!
          .from('navigation_steps')
          .insert(step.toJson())
          .select()
          .single();
      
      return NavigationStep.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating navigation step: $e');
      }
      rethrow;
    }
  }
  
  static Future<NavigationStep?> getActiveNavigationStep(String patientId) async {
    if (_isOfflineMode || _client == null) {
      return null;
    }
    try {
      final response = await _client!
          .from('navigation_steps')
          .select()
          .eq('patient_id', patientId)
          .eq('is_completed', false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) return null;
      return NavigationStep.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting navigation step: $e');
      }
      return null;
    }
  }

  // Pain Report Operations
  static Future<PainReport> createPainReport(PainReport report) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create pain report in Supabase');
    }
    try {
      final response = await _client!
          .from('pain_reports')
          .insert(report.toJson())
          .select()
          .single();
      
      return PainReport.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating pain report: $e');
      }
      rethrow;
    }
  }

  static Future<List<PainReport>> getUnacknowledgedPainReports() async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('pain_reports')
          .select()
          .eq('is_acknowledged', false)
          .order('reported_at', ascending: false);
      
      return (response as List)
          .map((json) => PainReport.fromJson(json))
          .toList();
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting pain reports: $e');
      }
      return [];
    }
  }

  static Future<void> acknowledgePainReport(String reportId) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot acknowledge pain report in Supabase');
    }
    try {
      await _client!
          .from('pain_reports')
          .update({'is_acknowledged': true})
          .eq('id', reportId);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error acknowledging pain report: $e');
      }
      rethrow;
    }
  }

  // Feedback Operations
  static Future<efoy.Feedback> createFeedback(efoy.Feedback feedback) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create feedback in Supabase');
    }
    try {
      final response = await _client!
          .from('feedback')
          .insert(feedback.toJson())
          .select()
          .single();
      
      return efoy.Feedback.fromJson(response);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating feedback: $e');
      }
      rethrow;
    }
  }

  static Future<List<efoy.Feedback>> getAllFeedback() async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('feedback')
          .select()
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((json) => efoy.Feedback.fromJson(json))
          .toList();
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting feedback: $e');
      }
      return [];
    }
  }

  // Emergency Alert Operations
  static Future<Map<String, dynamic>> createEmergencyAlert({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String location,
  }) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot create emergency alert in Supabase');
    }
    try {
      final alert = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'patient_id': patientId,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'location': location,
        'created_at': DateTime.now().toIso8601String(),
        'is_resolved': false,
      };

      final response = await _client!
          .from('emergency_alerts')
          .insert(alert)
          .select()
          .single();
      
      return response;
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error creating emergency alert: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getActiveEmergencyAlerts() async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('emergency_alerts')
          .select()
          .eq('is_resolved', false)
          .order('created_at', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error getting emergency alerts: $e');
      }
      return [];
    }
  }

  static Future<void> resolveEmergencyAlert(String alertId) async {
    if (_isOfflineMode || _client == null) {
      throw StateError('Offline mode: Cannot resolve emergency alert in Supabase');
    }
    try {
      await _client!
          .from('emergency_alerts')
          .update({'is_resolved': true})
          .eq('id', alertId);
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error resolving emergency alert: $e');
      }
      rethrow;
    }
  }

  // Check if patient exists with same name and phone
  static Future<Patient?> searchPatientsByNameAndPhone(String name, String phone) async {
    if (_isOfflineMode || _client == null) {
      return null;
    }
    try {
      // First check by phone number
      final byPhone = await _client!
          .from('patients')
          .select()
          .eq('phone_number', phone)
          .maybeSingle();
      
      if (byPhone != null) {
        final patient = Patient.fromJson(byPhone);
        // Check if name also matches (case-insensitive)
        if (patient.name.toLowerCase().trim() == name.toLowerCase().trim()) {
          return patient;
        }
      }
      
      return null;
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error searching patient by name and phone: $e');
      }
      return null;
    }
  }

  // Patient Search (for staff)
  static Future<List<Patient>> searchPatients(String query) async {
    if (_isOfflineMode || _client == null) {
      return [];
    }
    try {
      final response = await _client!
          .from('patients')
          .select()
          .or('name.ilike.%$query%,phone_number.ilike.%$query%,id.ilike.%$query%')
          .limit(20);
      
      return (response as List)
          .map((json) => Patient.fromJson(json))
          .toList();
    } catch (e) {
      if (!_shouldSkipError()) {
        print('Error searching patients: $e');
      }
      return [];
    }
  }
}

