import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app configuration and environment variables
class ConfigService {
  static const String _supabaseUrlKey = 'supabase_url';
  static const String _supabaseAnonKeyKey = 'supabase_anon_key';
  static const String _smsApiUrlKey = 'sms_api_url';
  static const String _smsApiKeyKey = 'sms_api_key';

  /// Get Supabase URL from environment or shared preferences
  static Future<String> getSupabaseUrl() async {
    // Try environment variable first
    const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    // Fallback to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_supabaseUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) return savedUrl;
    
    // Default Supabase URL
    return 'https://yokgynahghsdxftyqtbh.supabase.co';
  }

  /// Get Supabase anon key from environment or shared preferences
  static Future<String> getSupabaseAnonKey() async {
    // Try environment variable first
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Fallback to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_supabaseAnonKeyKey);
    if (savedKey != null && savedKey.isNotEmpty) return savedKey;
    
    // Default Supabase anon key
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlva2d5bmFoZ2hzZHhmdHlxdGJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NTk0MjAsImV4cCI6MjA4MjAzNTQyMH0.ir8QCuYDAzSDTlr2l4mDbfYIrjefmt9CHDqSvyW4hZM';
  }

  /// Get SMS API URL from environment or shared preferences
  static Future<String> getSmsApiUrl() async {
    // Try environment variable first
    const envUrl = String.fromEnvironment('SMS_API_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    // Fallback to shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_smsApiUrlKey) ?? 'https://api.yegara.com/v1/sms/send';
  }

  /// Get SMS API key from environment or shared preferences
  static Future<String> getSmsApiKey() async {
    // Try environment variable first
    const envKey = String.fromEnvironment('SMS_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Fallback to shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_smsApiKeyKey) ?? '';
  }

  /// Save configuration to shared preferences
  static Future<void> saveConfig({
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? smsApiUrl,
    String? smsApiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (supabaseUrl != null) {
      await prefs.setString(_supabaseUrlKey, supabaseUrl);
    }
    if (supabaseAnonKey != null) {
      await prefs.setString(_supabaseAnonKeyKey, supabaseAnonKey);
    }
    if (smsApiUrl != null) {
      await prefs.setString(_smsApiUrlKey, smsApiUrl);
    }
    if (smsApiKey != null) {
      await prefs.setString(_smsApiKeyKey, smsApiKey);
    }
  }

  /// Check if backend is configured
  static Future<bool> isBackendConfigured() async {
    final url = await getSupabaseUrl();
    final key = await getSupabaseAnonKey();
    return url.isNotEmpty && key.isNotEmpty;
  }

  /// Check if SMS is configured
  static Future<bool> isSmsConfigured() async {
    final key = await getSmsApiKey();
    return key.isNotEmpty;
  }

  /// Get staff credentials (for demo/testing purposes)
  /// In production, these should be stored securely or use Supabase Auth
  static Future<Map<String, String>> getStaffCredentials() async {
    // Return default credentials
    // These can be overridden via SharedPreferences if needed
    return {
      'nurse': 'nurse123',
      'doctor': 'doctor123',
      'admin': 'admin123',
    };
  }
}



