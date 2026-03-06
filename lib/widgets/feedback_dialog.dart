import 'package:flutter/material.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/models/feedback.dart' as efoy;

class FeedbackDialog extends StatelessWidget {
  final String patientId;
  final String patientPhone;

  const FeedbackDialog({
    super.key,
    required this.patientId,
    required this.patientPhone,
  });

  Future<void> _submitFeedback(BuildContext context, bool isPositive) async {
    final feedback = efoy.Feedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      isPositive: isPositive,
      submittedAt: DateTime.now(),
    );

    // Save locally
    await HiveService.saveFeedback(feedback);

    // Send SMS
    final smsMessage = isPositive
        ? 'Thank you! Service was good. እናመሰግናለን!'
        : 'Thank you for feedback. We will improve. እናመሰግናለን!';
    
    await SMSService.sendSMS(
      phoneNumber: patientPhone,
      message: smsMessage,
    );

    // Send to Supabase backend
    try {
      await SupabaseService.createFeedback(feedback);
    } catch (e) {
      print('Failed to sync feedback to backend: $e');
      // Continue anyway - data is saved locally
    }

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPositive ? 'Thank you!' : 'Thank you for your feedback!'),
          backgroundColor: Colors.green,
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
              Icons.feedback,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Was service good?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'የአገልግሎቱ ጥራት እንዴት ነበር?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitFeedback(context, true),
                    icon: const Icon(Icons.thumb_up, size: 32),
                    label: const Text('Yes', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitFeedback(context, false),
                    icon: const Icon(Icons.thumb_down, size: 32),
                    label: const Text('No', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'For button phone: Reply SMS with "1" (Yes) or "2" (No)',
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

