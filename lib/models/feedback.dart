import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';
part 'feedback.g.dart';

@HiveType(typeId: 6)
@freezed
class Feedback with _$Feedback {
  const factory Feedback({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'patient_id') required String patientId,
    @HiveField(2) @JsonKey(name: 'is_positive') required bool isPositive, // true = Yes/Good, false = No/Bad
    @HiveField(3) @JsonKey(name: 'submitted_at') required DateTime submittedAt,
    @HiveField(4) String? comment,
  }) = _Feedback;

  factory Feedback.fromJson(Map<String, dynamic> json) => _$FeedbackFromJson(json);
}



