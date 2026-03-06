import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/hive_service.dart';

/// Service to sync offline data with Supabase when online
class SyncService {
  /// Sync all pending data to Supabase
  static Future<void> syncAllPendingData() async {
    try {
      await syncPainReports();
      await syncFeedback();
      print('✅ All data synced successfully');
    } catch (e) {
      print('❌ Error syncing data: $e');
    }
  }

  /// Sync pain reports that haven't been synced
  static Future<void> syncPainReports() async {
    try {
      final localReports = HiveService.getAllPainReports();
      
      for (final report in localReports) {
        try {
          // Try to create in Supabase
          await SupabaseService.createPainReport(report);
          print('✅ Synced pain report: ${report.id}');
        } catch (e) {
          // If it already exists or other error, skip
          print('⚠️ Pain report ${report.id} sync skipped: $e');
        }
      }
    } catch (e) {
      print('Error syncing pain reports: $e');
    }
  }

  /// Sync feedback that hasn't been synced
  static Future<void> syncFeedback() async {
    try {
      final localFeedback = HiveService.getAllFeedback();
      
      for (final feedback in localFeedback) {
        try {
          // Try to create in Supabase
          await SupabaseService.createFeedback(feedback);
          print('✅ Synced feedback: ${feedback.id}');
        } catch (e) {
          // If it already exists or other error, skip
          print('⚠️ Feedback ${feedback.id} sync skipped: $e');
        }
      }
    } catch (e) {
      print('Error syncing feedback: $e');
    }
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    // Check if Supabase is configured and not in offline mode
    if (SupabaseService.isOfflineMode) {
      return false;
    }
    
    try {
      // Try a simple Supabase query to check connectivity
      final client = SupabaseService.client;
      if (client == null) {
        return false;
      }
      await client.from('patients').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}



