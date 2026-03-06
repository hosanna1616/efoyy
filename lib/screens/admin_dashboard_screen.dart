import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/providers/queue_provider.dart';
import 'package:efoy/providers/staff_provider.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/staff_efficiency_tools.dart';
import 'package:efoy/widgets/language_toggle.dart';
import 'package:efoy/widgets/custom_instruction_dialog.dart';
import 'package:efoy/screens/staff_login_screen.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/providers/pain_report_provider.dart';
import 'package:efoy/providers/emergency_alert_provider.dart';
import 'package:efoy/models/pain_report.dart';
import 'package:efoy/models/queue_entry.dart';
import 'package:efoy/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _roomController = TextEditingController(text: 'OPD Room 1');
  String _currentRoom = 'OPD Room 1';
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _roomController.addListener(() {
      setState(() {
        _currentRoom = _roomController.text;
      });
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffAuthProvider);
    
    // Redirect to login if not authenticated
    if (staff == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.staffDashboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.queue), text: 'Queue'),
            Tab(icon: Icon(Icons.sick), text: 'Pain Reports'),
            Tab(icon: Icon(Icons.warning), text: 'Emergencies'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          const LanguageToggle(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text(staff.name),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(staffAuthProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
                );
              }
            },
            tooltip: 'Logout',
          ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildQueueTab(),
            _buildPainReportsTab(),
            _buildEmergencyAlertsTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTab() {
    return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Selector
                GlassmorphicCard(
                  child: TextField(
                    controller: _roomController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.room,
                  prefixIcon: const Icon(Icons.room),
                  hintText: AppLocalizations.of(context)!.enterRoomName,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _currentRoom = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Staff Efficiency Tools
                GlassmorphicCard(
                  child: StaffEfficiencyTools(),
                ),

                const SizedBox(height: 20),

                // Queue List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                  AppLocalizations.of(context)!.liveQueueTitle(_currentRoom),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ref.invalidate(queueProvider(_currentRoom));
                      },
                  tooltip: AppLocalizations.of(context)!.refreshQueue,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, child) {
                    final queueAsync = ref.watch(queueProvider(_currentRoom));
                    
                    return queueAsync.when(
                      data: (queue) {
                        if (queue.isEmpty) {
                          return GlassmorphicCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.queue_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                AppLocalizations.of(context)!.noPatientsInQueue,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                AppLocalizations.of(context)!.queueWillAppearHere,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Call Next Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                              try {
                                  await ref.read(currentQueueEntryProvider.notifier).callNext(
                                        _currentRoom.trim(),
                                      );
                                  // Refresh the queue
                                  ref.invalidate(queueProvider(_currentRoom));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.nextPatientCalled),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                  }
                                },
                                icon: const Icon(Icons.call),
                            label: Text(AppLocalizations.of(context)!.callNextPatient),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                        // Queue List with Actions (sorted by queue_number - first come first serve)
                        ...queue.asMap().entries.map((entry) {
                          final index = entry.key;
                          final queueEntry = entry.value;
                          return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassmorphicCard(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                  backgroundColor: index == 0
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary,
                                        child: Text(
                                    '${queueEntry.queueNumber}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                title: Text(
                                  queueEntry.patientName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phone: ${queueEntry.patientPhone}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Position: ${queueEntry.currentPosition + 1} of ${queueEntry.totalInQueue}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: index == 0 ? Colors.green : null,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Est. Wait: ${_calculateEstimatedWaitTime(queueEntry.currentPosition)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    if (queueEntry.joinedAt != null)
                                      Text(
                                        'Joined: ${DateFormat('MMM dd, yyyy HH:mm').format(queueEntry.joinedAt)}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (queueEntry.calledAt != null)
                                      const Icon(Icons.check_circle, color: Colors.green),
                                    if (index == 0 && queueEntry.calledAt == null)
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () async {
                                          // Mark as served and remove from queue
                                          await _markAsServed(queueEntry);
                                        },
                                        tooltip: AppLocalizations.of(context)!.markAsServed,
                                        color: Colors.green,
                                    ),
                                    if (index == 0 && queueEntry.calledAt == null)
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          // Delete from queue
                                          await _deleteFromQueue(queueEntry);
                                        },
                                        tooltip: AppLocalizations.of(context)!.removeFromQueue,
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  _showPatientActions(context, queueEntry);
                                },
                              ),
                            ),
                          );
                        }),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, stackTrace) {
                        print('Queue error: $e');
                        return GlassmorphicCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Unable to load queue',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Error: ${e.toString()}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.invalidate(queueProvider(_currentRoom));
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPainReportsTab() {
    final painReportsAsync = ref.watch(unacknowledgedPainReportsProvider);
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(unacknowledgedPainReportsProvider);
        },
        child: painReportsAsync.when(
          data: (reports) => reports.isEmpty
              ? Center(
                  child: GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sick_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pain reports',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pain reports from patients will appear here',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassmorphicCard(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getPainColor(report.painLevel),
                            child: Text(
                              '${report.painLevel}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(report.patientName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(report.patientPhone),
                              Text(
                                'Pain Level: ${report.painLevel}/10',
                                style: TextStyle(
                                  color: _getPainColor(report.painLevel),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (report.notes != null && report.notes!.isNotEmpty)
                                Text(
                                  'Notes: ${report.notes}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              Text(
                                'Reported: ${DateFormat('MMM dd, HH:mm').format(report.reportedAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle),
                            color: Colors.green,
                            onPressed: () async {
                              await ref.read(acknowledgePainReportProvider(report.id).future);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pain report acknowledged'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            tooltip: 'Acknowledge',
                          ),
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $e'),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(unacknowledgedPainReportsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyAlertsTab() {
    final alertsAsync = ref.watch(activeEmergencyAlertsProvider);
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeEmergencyAlertsProvider);
        },
        child: alertsAsync.when(
          data: (alerts) => alerts.isEmpty
              ? Center(
                  child: GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No emergency alerts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Emergency alerts from patients will appear here',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassmorphicCard(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.warning, color: Colors.white),
                          ),
                          title: Text(alert['patient_name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert['patient_phone'] ?? ''),
                              if (alert['location'] != null)
                                Text('Location: ${alert['location']}'),
                              Text(
                                'Time: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(alert['created_at']))}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle),
                            color: Colors.green,
                            onPressed: () async {
                              await ref.read(resolveEmergencyAlertProvider(alert['id']).future);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Emergency alert resolved'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            tooltip: 'Resolve',
                          ),
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $e'),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(activeEmergencyAlertsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final queueAsync = ref.watch(queueProvider(_currentRoom));
                return queueAsync.when(
                  data: (queue) {
                    final activeCount = queue.where((e) => e.isActive && e.calledAt == null).length;
                    final calledCount = queue.where((e) => e.calledAt != null).length;
                    
                    return Column(
                      children: [
                        _buildStatCard(
                          'Active Queue',
                          '$_currentRoom',
                          '$activeCount patients',
                          Icons.queue,
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Called Today',
                          '$_currentRoom',
                          '$calledCount patients',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Consumer(
                          builder: (context, ref, child) {
                            final painReportsAsync = ref.watch(unacknowledgedPainReportsProvider);
                            return painReportsAsync.when(
                              data: (reports) => _buildStatCard(
                                'Pain Reports',
                                'Unacknowledged',
                                '${reports.length} reports',
                                Icons.sick,
                                Colors.orange,
                              ),
                              loading: () => _buildStatCard(
                                'Pain Reports',
                                'Loading...',
                                '...',
                                Icons.sick,
                                Colors.orange,
                              ),
                              error: (_, __) => _buildStatCard(
                                'Pain Reports',
                                'Error',
                                '0 reports',
                                Icons.sick,
                                Colors.orange,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer(
                          builder: (context, ref, child) {
                            final alertsAsync = ref.watch(activeEmergencyAlertsProvider);
                            return alertsAsync.when(
                              data: (alerts) => _buildStatCard(
                                'Emergency Alerts',
                                'Active',
                                '${alerts.length} alerts',
                                Icons.warning,
                                Colors.red,
                              ),
                              loading: () => _buildStatCard(
                                'Emergency Alerts',
                                'Loading...',
                                '...',
                                Icons.warning,
                                Colors.red,
                              ),
                              error: (_, __) => _buildStatCard(
                                'Emergency Alerts',
                                'Error',
                                '0 alerts',
                                Icons.warning,
                                Colors.red,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading stats'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle, String value, IconData icon, Color color) {
    return GlassmorphicCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ),
    );
  }

  Color _getPainColor(int level) {
    if (level >= 8) return Colors.red;
    if (level >= 5) return Colors.orange;
    return Colors.yellow;
  }


  String _calculateEstimatedWaitTime(int position) {
    final l10n = AppLocalizations.of(context)!;
    // Service time per person in minutes (configurable, default 5 minutes)
    const int serviceTimePerPerson = 5;
    
    // People ahead = position (0-based, so position 0 means no one ahead)
    final peopleAhead = position;
    
    if (peopleAhead == 0) {
      return l10n.now;
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

  Future<void> _markAsServed(QueueEntry entry) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      // Call next (marks current as served and notifies next person)
      await ref.read(currentQueueEntryProvider.notifier).callNext(_currentRoom.trim());
      
      // Refresh the queue
      ref.invalidate(queueProvider(_currentRoom));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.patientMarkedAsServed),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFromQueue(QueueEntry entry) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.removeFromQueueTitle),
          content: Text(l10n.areYouSureRemove(entry.patientName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.remove, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Delete from queue (marks as inactive and notifies next person)
        await ref.read(currentQueueEntryProvider.notifier).deleteFromQueue(
              entry.id,
              _currentRoom.trim(),
            );
        
        // Refresh the queue
        ref.invalidate(queueProvider(_currentRoom));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.removedFromQueue(entry.patientName)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPatientActions(BuildContext context, QueueEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(entry.patientName),
              subtitle: Text(entry.patientPhone),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Write Instruction'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => CustomInstructionDialog(
                    patientId: entry.patientId,
                    patientPhone: entry.patientPhone,
                    patientName: entry.patientName,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call Now'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(currentQueueEntryProvider.notifier).callNext(_currentRoom);
                ref.invalidate(queueProvider(_currentRoom));
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle),
              title: const Text('Remove from Queue'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await SupabaseService.removeFromQueue(entry.id);
                  ref.invalidate(queueProvider(_currentRoom));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Patient removed from queue'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
