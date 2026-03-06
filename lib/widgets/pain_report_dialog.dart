import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/models/pain_report.dart';

class PainReportDialog extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String patientPhone;

  const PainReportDialog({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
  });

  @override
  State<PainReportDialog> createState() => _PainReportDialogState();
}

class _PainReportDialogState extends State<PainReportDialog> {
  int _painLevel = 5;

  Future<void> _submitPainReport() async {
    // Vibrate on submit
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }

    // Create pain report
    final report = PainReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: widget.patientId,
      patientName: widget.patientName,
      patientPhone: widget.patientPhone,
      painLevel: _painLevel,
      reportedAt: DateTime.now(),
    );

    // Save locally
    await HiveService.savePainReport(report);

    // Send SMS
    await SMSService.sendSMS(
      phoneNumber: widget.patientPhone,
      message: 'Pain level $_painLevel reported. Nurse notified. ስለ ምቾት እናመሰግናለን!',
    );

    // Send to Supabase backend
    try {
      await SupabaseService.createPainReport(report);
    } catch (e) {
      print('Failed to sync pain report to backend: $e');
      // Continue anyway - data is saved locally
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pain level $_painLevel reported - Nurse notified'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sick,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Report Pain',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pain Level: $_painLevel',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _painLevel >= 7 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Number buttons 1-10
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(10, (index) {
                final level = index + 1;
                final isSelected = _painLevel == level;
                return GestureDetector(
                  onTap: () => setState(() => _painLevel = level),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (level >= 7 ? Colors.red : Colors.orange)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (level >= 7 ? Colors.red : Colors.orange)
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitPainReport,
                icon: const Icon(Icons.send),
                label: const Text('Report Pain'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'For button phone: Reply SMS with "Pain $_painLevel"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

