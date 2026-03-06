import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/services/supabase_service.dart';

final activeEmergencyAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await SupabaseService.getActiveEmergencyAlerts();
  } catch (e) {
    print('Error loading emergency alerts: $e');
    return [];
  }
});

final resolveEmergencyAlertProvider = FutureProvider.family<void, String>((ref, alertId) async {
  await SupabaseService.resolveEmergencyAlert(alertId);
  ref.invalidate(activeEmergencyAlertsProvider);
});

