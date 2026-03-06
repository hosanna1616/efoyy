import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/models/patient.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

final currentPatientProvider = StateNotifierProvider<CurrentPatientNotifier, Patient?>((ref) {
  return CurrentPatientNotifier();
});

class CurrentPatientNotifier extends StateNotifier<Patient?> {
  CurrentPatientNotifier() : super(null) {
    _loadCurrentPatient();
  }
  
  Future<void> _loadCurrentPatient() async {
    final patient = HiveService.getCurrentPatient();
    if (patient != null) {
      state = patient;
    }
  }
  
  Future<void> setPatient(Patient patient) async {
    // Save to local storage first for immediate access
    await HiveService.savePatient(patient);
    await HiveService.setCurrentPatient(patient.id);
    
    // Sync to Supabase if online (for cross-device access)
    try {
      if (!SupabaseService.isOfflineMode && SupabaseService.client != null) {
        // Check if patient exists in Supabase
        final existing = await SupabaseService.getPatientByPhone(patient.phoneNumber);
        if (existing == null) {
          // Create in Supabase if doesn't exist
          await SupabaseService.createPatient(patient);
        } else {
          // Update in Supabase if exists
          await SupabaseService.updatePatient(patient);
        }
      }
    } catch (e) {
      // If sync fails, continue with local storage only
      print('Warning: Could not sync patient to Supabase: $e');
    }
    
    state = patient;
  }
  
  Future<void> updatePatient(Patient patient) async {
    try {
      final updated = await SupabaseService.updatePatient(patient);
      await HiveService.savePatient(updated);
      state = updated;
    } catch (e) {
      // If offline, just update locally
      await HiveService.savePatient(patient);
      state = patient;
    }
  }
  
  Future<Patient?> registerPatient({
    required String phoneNumber,
    required String name,
  }) async {
    try {
      // Check if patient exists with same phone number
      var patient = await SupabaseService.getPatientByPhone(phoneNumber);
      
      if (patient != null) {
        // Check if name also matches (duplicate registration)
        if (patient.name.toLowerCase().trim() == name.toLowerCase().trim()) {
          throw Exception('A patient with the same name and phone number is already registered. Please login instead.');
        }
        // Phone exists but name is different - update the name
        patient = patient.copyWith(name: name);
        patient = await SupabaseService.updatePatient(patient);
      } else {
        // Check if patient exists with same name and phone (case-insensitive)
        final existingPatient = await SupabaseService.searchPatientsByNameAndPhone(name, phoneNumber);
        if (existingPatient != null) {
          throw Exception('A patient with the same name and phone number is already registered. Please login instead.');
        }
        
        // Generate patient ID
        final patientId = 'EFOY-${DateTime.now().millisecondsSinceEpoch % 10000}';
        
        patient = Patient(
          id: patientId,
          phoneNumber: phoneNumber,
          name: name,
          createdAt: DateTime.now(),
        );
        
        patient = await SupabaseService.createPatient(patient);
      }
      
      await setPatient(patient);
      return patient;
    } catch (e) {
      print('Error registering patient: $e');
      // Re-throw validation errors
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      // Create offline patient only if it's a network error
      final patientId = 'EFOY-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final patient = Patient(
        id: patientId,
        phoneNumber: phoneNumber,
        name: name,
        createdAt: DateTime.now(),
      );
      await setPatient(patient);
      return patient;
    }
  }

  Future<void> clearPatient() async {
    await HiveService.clearCurrentPatient();
    state = null;
  }
}




