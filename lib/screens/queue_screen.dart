import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/providers/queue_provider.dart';
import 'package:efoy/models/queue_entry.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/queue_orb_widget.dart';
import 'package:efoy/widgets/pain_report_dialog.dart';
import 'package:efoy/widgets/emergency_help_button.dart';
import 'package:efoy/widgets/language_toggle.dart';
import 'package:efoy/generated/l10n/app_localizations.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final _roomController = TextEditingController(text: 'OPD Room 1');
  Timer? _positionUpdateTimer;
  int? _lastNotifiedPosition;

  @override
  void initState() {
    super.initState();
    // Monitor queue entry for position changes
    _positionUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final queueEntry = ref.read(currentQueueEntryProvider);
      if (queueEntry != null && queueEntry.isActive) {
        // Check if position changed to 0 (patient's turn)
        if (queueEntry.currentPosition == 0 && 
            _lastNotifiedPosition != 0 &&
            queueEntry.calledAt == null) {
          _showTurnNotification();
          _lastNotifiedPosition = 0;
        } else if (queueEntry.currentPosition != _lastNotifiedPosition) {
          _lastNotifiedPosition = queueEntry.currentPosition;
        }
      }
    });
  }

  void _showTurnNotification() {
    final queueEntry = ref.read(currentQueueEntryProvider);
    if (queueEntry != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your turn! Go to ${queueEntry.room}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);
    final queueEntry = ref.watch(currentQueueEntryProvider);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('OPD Queue')),
        body: const Center(
          child: Text('Please register first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPD Queue'),
        actions: const [
          LanguageToggle(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: queueEntry == null
              ? _buildJoinQueueView(context, patient)
              : _buildQueueStatusView(context, queueEntry),
        ),
      ),
    );
  }

  Widget _buildJoinQueueView(BuildContext context, patient) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassmorphicCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.queue,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.joinQueue,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.room,
                  prefixIcon: const Icon(Icons.room),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final l10n = AppLocalizations.of(context)!;
                    if (_roomController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.pleaseEnterRoomName),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    try {
                      await ref.read(currentQueueEntryProvider.notifier).joinQueue(
                            patientId: patient.id,
                            patientName: patient.name,
                            patientPhone: patient.phoneNumber,
                            room: _roomController.text.trim(),
                          );
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.successfullyJoinedQueue),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.errorJoiningQueue}: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.joinQueue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueStatusView(BuildContext context, QueueEntry entry) {
    final patient = ref.watch(currentPatientProvider);
    final queueAsync = ref.watch(queueProvider(entry.room));

    if (patient == null) {
      return const Center(child: Text('Patient not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 3D Glowing Orb
          QueueOrbWidget(
            position: entry.currentPosition,
            total: entry.totalInQueue > 0 ? entry.totalInQueue : 1,
            queueNumber: entry.queueNumber,
          ),

          const SizedBox(height: 30),

          // Pain Report & Emergency Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PainReportDialog(
                        patientId: patient.id,
                        patientName: patient.name,
                        patientPhone: patient.phoneNumber,
                      ),
                    );
                  },
                  icon: const Icon(Icons.sick),
                  label: const Text('Report Pain'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EmergencyHelpButton(
                  patientId: patient.id,
                  patientName: patient.name,
                  patientPhone: patient.phoneNumber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Queue Details - Use live queue data for accurate position
          queueAsync.when(
            data: (queue) {
              // Find current entry in queue to get accurate position
              final currentIndex = queue.indexWhere((e) => e.id == entry.id);
              final actualPosition = currentIndex >= 0 ? currentIndex : entry.currentPosition;
              final actualTotal = queue.isNotEmpty ? queue.length : (entry.totalInQueue > 0 ? entry.totalInQueue : 1);
              
              return GlassmorphicCard(
                child: Column(
                  children: [
                    Text(
                      'Queue #${entry.queueNumber}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(AppLocalizations.of(context)!.room, entry.room),
                    _buildInfoRow(AppLocalizations.of(context)!.position, '${actualPosition + 1} / $actualTotal'),
                    _buildInfoRow(AppLocalizations.of(context)!.estimatedWait, _calculateEstimatedWaitTime(context, actualPosition)),
                    if (entry.calledAt != null || actualPosition == 0)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active, color: Colors.green, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.yourTurn,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.goToRoom(entry.room),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.buttonPhoneUsersCheckSMS,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => GlassmorphicCard(
              child: Column(
                children: [
                  Text(
                    'Queue #${entry.queueNumber}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Room', entry.room),
                  _buildInfoRow('Position', '${entry.currentPosition + 1} / ${entry.totalInQueue > 0 ? entry.totalInQueue : 1}'),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
            error: (e, _) => GlassmorphicCard(
              child: Column(
                children: [
                  Text(
                    'Queue #${entry.queueNumber}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Room', entry.room),
                  _buildInfoRow('Position', '${entry.currentPosition + 1} / ${entry.totalInQueue > 0 ? entry.totalInQueue : 1}'),
                  Text('Error loading queue: $e'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Live Queue List
          queueAsync.when(
            data: (queue) => GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Queue',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...queue.take(10).map((e) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: e.id == entry.id
                              ? Colors.green
                              : Colors.grey,
                          child: Text(
                            '${e.queueNumber}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(e.patientName),
                        trailing: e.id == entry.id
                            ? const Icon(Icons.person, color: Colors.green)
                            : null,
                      )),
                ],
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  String _calculateEstimatedWaitTime(BuildContext context, int position) {
    final l10n = AppLocalizations.of(context)!;
    // Service time per person in minutes (configurable, default 5 minutes)
    const int serviceTimePerPerson = 5;
    
    // People ahead = position (0-based, so position 0 means no one ahead)
    final peopleAhead = position;
    
    if (peopleAhead == 0) {
      return l10n.yourTurnNow;
    }
    
    final estimatedMinutes = peopleAhead * serviceTimePerPerson;
    
    if (estimatedMinutes < 60) {
      return l10n.minutes(estimatedMinutes);
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return l10n.hoursMinutes(hours, minutes);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

