import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/models/navigation_step.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/data/hospital_data.dart';

final activeNavigationProvider = FutureProvider.family<NavigationStep?, String>((ref, patientId) async {
  try {
    final step = await SupabaseService.getActiveNavigationStep(patientId);
    if (step != null) {
      await HiveService.saveNavigationStep(step);
      return step;
    }
  } catch (e) {
    print('Error getting navigation step: $e');
  }
  
  // Fallback to offline
  return HiveService.getActiveNavigationStep(patientId);
});

final createNavigationProvider = FutureProvider.family<NavigationStep, CreateNavigationParams>((ref, params) async {
  try {
    final location = HospitalData.getLocationByType(params.destinationType);
    
    final step = NavigationStep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: params.patientId,
      destination: location.name,
      destinationType: params.destinationType,
      directions: location.directions,
      latitude: location.latitude,
      longitude: location.longitude,
      createdAt: DateTime.now(),
    );
    
    final created = await SupabaseService.createNavigationStep(step);
    await HiveService.saveNavigationStep(created);
    
    // Send SMS directions for button phone users
    if (!HiveService.isSmartphone()) {
      await SMSService.sendNavigationSMS(
        phoneNumber: params.patientPhone,
        destination: location.name,
        directions: location.directions,
      );
    }
    
    return created;
  } catch (e) {
    // Create offline
    final location = HospitalData.getLocationByType(params.destinationType);
    final step = NavigationStep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: params.patientId,
      destination: location.name,
      destinationType: params.destinationType,
      directions: location.directions,
      latitude: location.latitude,
      longitude: location.longitude,
      createdAt: DateTime.now(),
    );
    await HiveService.saveNavigationStep(step);
    return step;
  }
});

class CreateNavigationParams {
  final String patientId;
  final String patientPhone;
  final String destinationType; // Lab, X-Ray, Pharmacy, OPD
  
  CreateNavigationParams({
    required this.patientId,
    required this.patientPhone,
    required this.destinationType,
  });
}


