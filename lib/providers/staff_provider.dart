import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:efoy/services/config_service.dart';

class Staff {
  final String username;
  final String role; // 'nurse' or 'doctor'
  final String name;

  Staff({
    required this.username,
    required this.role,
    required this.name,
  });
}

class StaffAuthNotifier extends StateNotifier<Staff?> {
  StaffAuthNotifier() : super(null) {
    _loadSavedStaff();
  }

  Future<void> _loadSavedStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('staff_username');
    final role = prefs.getString('staff_role');
    final name = prefs.getString('staff_name');
    
    if (username != null && role != null && name != null) {
      state = Staff(username: username, role: role, name: name);
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simple authentication (in production, use Supabase Auth or secure backend)
    // Get credentials from ConfigService
    final credentialsMap = await ConfigService.getStaffCredentials();
    
    final staffCredentials = {
      'nurse': {
        'password': credentialsMap['nurse'] ?? 'nurse123', 
        'role': 'nurse', 
        'name': 'Nurse Demo'
      },
      'doctor': {
        'password': credentialsMap['doctor'] ?? 'doctor123', 
        'role': 'doctor', 
        'name': 'Doctor Demo'
      },
      'admin': {
        'password': credentialsMap['admin'] ?? 'admin123', 
        'role': 'nurse', 
        'name': 'Admin Demo'
      },
    };

    final credentials = staffCredentials[username.toLowerCase()];
    
    if (credentials != null && credentials['password'] == password) {
      final staff = Staff(
        username: username.toLowerCase(),
        role: credentials['role'] as String,
        name: credentials['name'] as String,
      );
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('staff_username', staff.username);
      await prefs.setString('staff_role', staff.role);
      await prefs.setString('staff_name', staff.name);
      
      state = staff;
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('staff_username');
    await prefs.remove('staff_role');
    await prefs.remove('staff_name');
    state = null;
  }
}

final staffAuthProvider = StateNotifierProvider<StaffAuthNotifier, Staff?>((ref) {
  return StaffAuthNotifier();
});
