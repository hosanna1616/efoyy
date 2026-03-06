import 'package:dio/dio.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/config_service.dart';

class SMSService {
  static final Dio _dio = Dio();
  
  // Get SMS API configuration dynamically
  static Future<String> _getSmsApiUrl() async {
    return await ConfigService.getSmsApiUrl();
  }

  static Future<String> _getSmsApiKey() async {
    return await ConfigService.getSmsApiKey();
  }
  
  // Send SMS via Yegara or AfroMessage with retry logic
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
    int maxRetries = 3,
  }) async {
    try {
      // Format phone number (Ethiopian format: +251XXXXXXXXX)
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      
      // Get SMS API configuration
      final smsApiUrl = await _getSmsApiUrl();
      final smsApiKey = await _getSmsApiKey();
      
      // For development/testing, log instead of sending
      if (smsApiKey.isEmpty) {
        print('📱 SMS (Mock): To $formattedPhone\n$message');
        await HiveService.saveSMSToHistory(formattedPhone, message);
        return true;
      }
      
      // Retry logic for reliability
      int attempts = 0;
      while (attempts < maxRetries) {
        try {
          // Yegara SMS API format
          final response = await _dio.post(
            smsApiUrl,
            data: {
              'to': formattedPhone,
              'message': message,
              'from': 'EFOY',
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $smsApiKey',
                'Content-Type': 'application/json',
              },
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            await HiveService.saveSMSToHistory(formattedPhone, message);
            print('✅ SMS sent successfully to $formattedPhone');
            return true;
          }
        } catch (e) {
          attempts++;
          if (attempts >= maxRetries) {
            print('❌ SMS failed after $maxRetries attempts: $e');
            // Save to history even on failure for debugging
            await HiveService.saveSMSToHistory(formattedPhone, message);
            return false;
          }
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempts));
        }
      }
      
      return false;
    } catch (e) {
      print('Error sending SMS: $e');
      // In case of error, still save to history for debugging
      await HiveService.saveSMSToHistory(phoneNumber, message);
      return false;
    }
  }
  
  // Format phone number to Ethiopian format
  static String _formatPhoneNumber(String phone) {
    // Remove all non-digits
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // If starts with 0, replace with +251
    if (cleaned.startsWith('0')) {
      cleaned = '+251${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('251')) {
      cleaned = '+251$cleaned';
    } else {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }
  
  // Send queue update SMS
  static Future<void> sendQueueUpdate({
    required String phoneNumber,
    required int queueNumber,
    required int position,
    required int totalInQueue,
    required String room,
  }) async {
    final estimatedMinutes = position * 10; // ~10 min per patient
    
    final message = position == 0
        ? 'ተራዎ ነው! ወደ $room ይሂዱ'
        : 'ተራዎ #$queueNumber ነው! ቦታ: $position/$totalInQueue. ግምታዊ ጊዜ: ~$estimatedMinutes ደቂቃ';
    
    await sendSMS(phoneNumber: phoneNumber, message: message);
  }
  
  // Send appointment reminder SMS
  static Future<void> sendAppointmentReminder({
    required String phoneNumber,
    required String patientId,
    required DateTime appointmentDate,
    required String room,
  }) async {
    final dateStr = _formatDateAmharic(appointmentDate);
    final message = 'እንዳስታወሱ: የእርስዎ ቀጠሮ በ$dateStr በ$room ነው። ID: $patientId';
    
    await sendSMS(phoneNumber: phoneNumber, message: message);
  }
  
  // Send instruction SMS
  static Future<void> sendInstructionSMS({
    required String phoneNumber,
    required String title,
    required List<String> steps,
  }) async {
    final stepsText = steps.asMap().entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');
    
    final message = '$title\n\n$stepsText';
    
    await sendSMS(phoneNumber: phoneNumber, message: message);
  }
  
  // Send navigation directions SMS
  static Future<void> sendNavigationSMS({
    required String phoneNumber,
    required String destination,
    required List<String> directions,
  }) async {
    final directionsText = directions.join(' → ');
    final message = 'ወደ $destination:\n$directionsText';
    
    await sendSMS(phoneNumber: phoneNumber, message: message);
  }
  
  // Format date in Amharic-friendly format
  static String _formatDateAmharic(DateTime date) {
    final months = [
      'ጃንዋሪ', 'ፌብሩዋሪ', 'ማርች', 'ኤፕሪል', 'ሜይ', 'ጁን',
      'ጁላይ', 'ኦገስት', 'ሴፕቴምበር', 'ኦክቶበር', 'ኖቬምበር', 'ዲሴምበር'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}


