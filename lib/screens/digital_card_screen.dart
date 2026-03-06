import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/language_toggle.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DigitalCardScreen extends ConsumerStatefulWidget {
  const DigitalCardScreen({super.key});

  @override
  ConsumerState<DigitalCardScreen> createState() => _DigitalCardScreenState();
}

class _DigitalCardScreenState extends ConsumerState<DigitalCardScreen> {
  final GlobalKey _cardKey = GlobalKey();

  Future<void> _downloadCard() async {
    try {
      if (!mounted) return;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Preparing card...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for next frame to ensure widget is fully rendered
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force a rebuild to ensure RepaintBoundary is ready
      if (mounted) {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      final RenderRepaintBoundary? boundary = 
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to capture card image. Please try again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Capture the image with high quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to convert image to PNG'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final imageBytes = byteData.buffer.asUint8List();

      // Get directory - use Downloads on Windows if available, otherwise documents
      Directory directory;
      String filePath;
      try {
        if (Platform.isWindows) {
          // Try to use Downloads folder on Windows
          final userProfile = Platform.environment['USERPROFILE'];
          if (userProfile != null && userProfile.isNotEmpty) {
            final downloadsPath = '$userProfile\\Downloads';
            directory = Directory(downloadsPath);
            if (await directory.exists()) {
              // Use Downloads folder
              final fileName = 'efoy_card_${DateTime.now().millisecondsSinceEpoch}.png';
              filePath = '$downloadsPath\\$fileName';
            } else {
              // Fallback to Documents
              final documentsPath = '$userProfile\\Documents';
              directory = Directory(documentsPath);
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
              final fileName = 'efoy_card_${DateTime.now().millisecondsSinceEpoch}.png';
              filePath = '$documentsPath\\$fileName';
            }
          } else {
            // Fallback if USERPROFILE not available - use path_provider
            directory = await getApplicationDocumentsDirectory();
            final fileName = 'efoy_card_${DateTime.now().millisecondsSinceEpoch}.png';
            filePath = '${directory.path}/$fileName';
          }
        } else {
          // Non-Windows: use path_provider
          directory = await getApplicationDocumentsDirectory();
          final fileName = 'efoy_card_${DateTime.now().millisecondsSinceEpoch}.png';
          filePath = '${directory.path}/$fileName';
        }
      } catch (e) {
        // If path_provider fails, use current directory as last resort
        directory = Directory.current;
        final fileName = 'efoy_card_${DateTime.now().millisecondsSinceEpoch}.png';
        filePath = '${directory.path}/$fileName';
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File(filePath);
      
      // Write the file
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        try {
          // Try to share/open the file - use shareXFiles for better compatibility
          if (Platform.isWindows) {
            // On Windows, use shareXFiles with proper path handling
            try {
              await Share.shareXFiles(
                [XFile(filePath)],
                text: 'My Efoy Digital Card',
                subject: 'Efoy Digital Card',
              );
            } catch (shareXError) {
              // Fallback to regular share if shareXFiles fails
              await Share.share(
                'My Efoy Digital Card\n\nSaved to: $filePath',
                subject: 'Efoy Digital Card',
              );
            }
          } else {
            // Non-Windows: use shareXFiles
            await Share.shareXFiles(
              [XFile(filePath)],
              text: 'My Efoy Digital Card',
              subject: 'Efoy Digital Card',
            );
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card saved successfully!'),
                    const SizedBox(height: 4),
                    Text(
                      'Location: $filePath',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } catch (shareError) {
          // If sharing fails, at least show where it was saved
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card saved successfully!'),
                    const SizedBox(height: 4),
                    Text(
                      'Location: $filePath',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You can find it in your Downloads or Documents folder.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 7),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving card: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Error in _downloadCard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Digital Card')),
        body: const Center(
          child: Text('Please register first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Card'),
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
          child: Column(
            children: [
              // Download Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _downloadCard,
                  icon: const Icon(Icons.download),
                  label: const Text('Download as PNG'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              // Card Content (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: Column(
                      children: [
                // QR Code Card
                GlassmorphicCard(
                  child: Column(
                    children: [
                      QrImageView(
                        data: patient.id,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        patient.id,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Patient Info Card
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              patient.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  patient.phoneNumber,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        context,
                        'Patient ID',
                        patient.id,
                        Icons.badge,
                      ),
                      if (patient.nextAppointment != null)
                        _buildInfoRow(
                          context,
                          'Next Appointment',
                          DateFormat('MMM dd, yyyy').format(patient.nextAppointment!),
                          Icons.calendar_today,
                        ),
                      if (patient.nextAppointmentRoom != null)
                        _buildInfoRow(
                          context,
                          'Room',
                          patient.nextAppointmentRoom!,
                          Icons.room,
                        ),
                      if (patient.createdAt != null)
                        _buildInfoRow(
                          context,
                          'Member Since',
                          DateFormat('MMM yyyy').format(patient.createdAt!),
                          Icons.access_time,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Medical History
                if (patient.medicalHistory != null && patient.medicalHistory!.isNotEmpty)
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...patient.medicalHistory!.map(
                          (history) => ListTile(
                            leading: const Icon(Icons.medical_information),
                            title: Text(history),
                          ),
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


