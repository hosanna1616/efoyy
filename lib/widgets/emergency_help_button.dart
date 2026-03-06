import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/supabase_service.dart';

class EmergencyHelpButton extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String patientPhone;

  const EmergencyHelpButton({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
  });

  Future<void> _requestEmergencyHelp(BuildContext context) async {
    // Strong vibration
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 200, 500], repeat: 2);
    }

    // Send SMS alert
    await SMSService.sendSMS(
      phoneNumber: patientPhone,
      message: 'Emergency help requested! Nurse coming. አስቸኳይ እርዳታ ተጠይቋል!',
    );

    // Send to Supabase backend
    try {
      await SupabaseService.createEmergencyAlert(
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        location: 'Queue Screen', // Could be dynamic
      );
    } catch (e) {
      print('Failed to sync emergency alert to backend: $e');
      // Continue anyway - SMS sent
    }

    // Show full-screen alert
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.red,
          title: const Text(
            'Help Requested!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Nurse coming to help you now.\n\nአስቸኳይ እርዳታ ተጠይቋል! ነርስ እየመጣ ነው!',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _requestEmergencyHelp(context),
      icon: const Icon(Icons.emergency),
      label: const Text('Need Help Now'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}

