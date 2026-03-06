import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/providers/navigation_provider.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final FlutterTts _tts = FlutterTts();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('am-ET');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speakDirections(List<String> directions) async {
    final text = directions.join('. ');
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(
          child: Text('Please register first'),
        ),
      );
    }

    final navigationAsync = ref.watch(activeNavigationProvider(patient.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (type) async {
              await ref.read(createNavigationProvider(CreateNavigationParams(
                patientId: patient.id,
                patientPhone: patient.phoneNumber,
                destinationType: type,
              )).future);
              // Refresh the active navigation provider
              ref.invalidate(activeNavigationProvider(patient.id));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Lab', child: Text('Go to Lab')),
              const PopupMenuItem(value: 'X-Ray', child: Text('Go to X-Ray')),
              const PopupMenuItem(value: 'Pharmacy', child: Text('Go to Pharmacy')),
              const PopupMenuItem(value: 'OPD', child: Text('Go to OPD')),
            ],
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
        child: SafeArea(
          child: navigationAsync.when(
            data: (step) {
              if (step == null) {
                return Center(
                  child: GlassmorphicCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.navigation_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active navigation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select a destination from the menu above',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Show menu programmatically
                            showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                MediaQuery.of(context).size.width - 100,
                                100,
                                0,
                                0,
                              ),
                              items: [
                                const PopupMenuItem(value: 'Lab', child: Text('Go to Lab')),
                                const PopupMenuItem(value: 'X-Ray', child: Text('Go to X-Ray')),
                                const PopupMenuItem(value: 'Pharmacy', child: Text('Go to Pharmacy')),
                                const PopupMenuItem(value: 'OPD', child: Text('Go to OPD')),
                              ],
                            ).then((type) {
                              if (type != null) {
                                ref.read(createNavigationProvider(CreateNavigationParams(
                                  patientId: patient.id,
                                  patientPhone: patient.phoneNumber,
                                  destinationType: type,
                                )).future).then((_) {
                                  ref.invalidate(activeNavigationProvider(patient.id));
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.add_location),
                          label: const Text('Select Destination'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Map View
                  Expanded(
                    flex: 2,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          step.latitude ?? 11.5937,
                          step.longitude ?? 37.3907,
                        ),
                        initialZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.efoy.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                step.latitude ?? 11.5937,
                                step.longitude ?? 37.3907,
                              ),
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Directions Card
                  Expanded(
                    flex: 1,
                    child: GlassmorphicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'To: ${step.destination}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () => _speakDirections(step.directions),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: step.directions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          step.directions[index],
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Mark as completed
                              final completed = step.copyWith(isCompleted: true);
                              await HiveService.saveNavigationStep(completed);
                              // Refresh navigation
                              ref.invalidate(activeNavigationProvider(patient.id));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Navigation completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: const Text('I Arrived'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }
}

