import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pain_report.freezed.dart';
part 'pain_report.g.dart';

@HiveType(typeId: 5)
@freezed
class PainReport with _$PainReport {
  const factory PainReport({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'patient_id') required String patientId,
    @HiveField(2) @JsonKey(name: 'patient_name') required String patientName,
    @HiveField(3) @JsonKey(name: 'patient_phone') required String patientPhone,
    @HiveField(4) @JsonKey(name: 'pain_level') required int painLevel, // 1-10
    @HiveField(5) @JsonKey(name: 'reported_at') required DateTime reportedAt,
    @HiveField(6) @JsonKey(name: 'is_acknowledged') @Default(false) bool isAcknowledged,
    @HiveField(7) String? notes,
  }) = _PainReport;

  factory PainReport.fromJson(Map<String, dynamic> json) => _$PainReportFromJson(json);
}



