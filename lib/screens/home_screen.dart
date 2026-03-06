import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/feedback_dialog.dart';
import 'package:efoy/widgets/language_toggle.dart';
import 'package:efoy/generated/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _easterEggController = TextEditingController();

  @override
  void dispose() {
    _easterEggController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Easter Egg
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Logo/Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF078930), // Green
                                    Color(0xFFFCDD09), // Yellow
                                    Color(0xFFDA1212), // Red
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'እፎይ',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  l10n.appTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (patient != null)
                          PopupMenuButton<String>(
                            child: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                patient.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            onSelected: (value) {
                              if (value == 'logout') {
                                ref.read(currentPatientProvider.notifier).clearPatient();
                                context.go('/');
                              } else if (value == 'settings') {
                                context.push('/settings');
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    const Icon(Icons.settings),
                                    const SizedBox(width: 8),
                                    Text(l10n.settings),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(width: 8),
                        const LanguageToggle(),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: patient == null
                    ? _buildRegistrationPrompt(context)
                    : _buildMainMenu(context, patient),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: GlassmorphicCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.registerToGetStarted,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
              ElevatedButton.icon(
              onPressed: () => context.push('/register'),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.register),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/patient-login'),
              icon: const Icon(Icons.login),
              label: Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, patient) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Patient Info Card
        GlassmorphicCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                patient.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(patient.name),
            subtitle: Text('ID: ${patient.id}'),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () => context.push('/card'),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Main Features Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildFeatureCard(
              context,
              icon: Icons.queue,
              title: l10n.opdQueue,
              subtitle: l10n.checkYourTurn,
              color: Colors.blue,
              onTap: () => context.push('/queue'),
            ),
            _buildFeatureCard(
              context,
              icon: Icons.badge,
              title: l10n.digitalCard,
              subtitle: l10n.viewYourCard,
              color: Colors.green,
              onTap: () => context.push('/card'),
            ),
            _buildFeatureCard(
              context,
              icon: Icons.article,
              title: l10n.instructions,
              subtitle: l10n.viewInstructions,
              color: Colors.orange,
              onTap: () => context.push('/instructions'),
            ),
            _buildFeatureCard(
              context,
              icon: Icons.navigation,
              title: l10n.navigation,
              subtitle: l10n.getDirections,
              color: Colors.purple,
              onTap: () => context.push('/navigation'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Admin Access
        TextButton.icon(
          onPressed: () => context.push('/admin'),
          icon: const Icon(Icons.admin_panel_settings),
          label: Text(l10n.staffDashboard),
        ),

        const SizedBox(height: 20),

        // Settings
        TextButton.icon(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings),
          label: Text(l10n.settings),
        ),

        const SizedBox(height: 20),

        // Feedback Button
        if (patient != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FeedbackDialog(
                    patientId: patient.id,
                    patientPhone: patient.phoneNumber,
                  ),
                );
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Give Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


