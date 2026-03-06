import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/models/pain_report.dart';

final unacknowledgedPainReportsProvider = FutureProvider<List<PainReport>>((ref) async {
  try {
    return await SupabaseService.getUnacknowledgedPainReports();
  } catch (e) {
    print('Error loading pain reports: $e');
    return [];
  }
});

final acknowledgePainReportProvider = FutureProvider.family<void, String>((ref, reportId) async {
  await SupabaseService.acknowledgePainReport(reportId);
  ref.invalidate(unacknowledgedPainReportsProvider);
});

