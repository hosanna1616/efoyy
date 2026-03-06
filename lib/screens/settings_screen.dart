import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/providers/language_provider.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/language_toggle.dart';
import 'package:efoy/generated/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSmartphone = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isSmartphone = HiveService.isSmartphone();
    setState(() {
      _isSmartphone = isSmartphone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Patient Info
              if (patient != null)
                GlassmorphicCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        patient.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(patient.name),
                    subtitle: Text('ID: ${patient.id}\nPhone: ${patient.phoneNumber}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile editing coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Device Type
              GlassmorphicCard(
                child: SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.smartphoneMode),
                  subtitle: Text(
                    AppLocalizations.of(context)!.smartphoneModeDescription,
                  ),
                  value: _isSmartphone,
                  onChanged: (value) async {
                    await HiveService.setPhoneType(value);
                    setState(() {
                      _isSmartphone = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? AppLocalizations.of(context)!.smartphoneModeEnabled
                              : AppLocalizations.of(context)!.buttonPhoneModeEnabled,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Language Settings
              GlassmorphicCard(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.switchToAmharic),
                  subtitle: Text(ref.watch(languageProvider).languageCode == 'am' ? 'አማርኛ' : 'English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Language toggle is in app bar, but can add more options here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.useLanguageToggle),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Notifications
              GlassmorphicCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                    ),
                    SwitchListTile(
                      title: const Text('Queue Updates'),
                      subtitle: const Text('Get notified when your queue position changes'),
                      value: true, // TODO: Implement notification preferences
                      onChanged: (value) {
                        // TODO: Save notification preference
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Instruction Alerts'),
                      subtitle: const Text('Get notified when new instructions are available'),
                      value: true,
                      onChanged: (value) {
                        // TODO: Save notification preference
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Data Management
              GlassmorphicCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Data Management'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_sync),
                      title: const Text('Sync Data'),
                      subtitle: const Text('Sync offline data with server'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        // TODO: Implement sync
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data sync initiated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Clear all cached data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showClearCacheDialog();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About
              GlassmorphicCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                    ),
                    ListTile(
                      title: const Text('Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      title: const Text('Efoy - Patient Relief App'),
                      subtitle: const Text('For Ethiopian public hospitals'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout/Unregister
              if (patient != null)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showUnregisterDialog();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. You will need to sync again when online.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showUnregisterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'This will log you out. You can login again using your phone number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(currentPatientProvider.notifier).clearPatient();
              Navigator.pop(context);
              if (mounted) {
                context.go('/');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

