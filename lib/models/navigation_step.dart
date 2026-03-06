import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_step.freezed.dart';
part 'navigation_step.g.dart';

@HiveType(typeId: 4)
@freezed
class NavigationStep with _$NavigationStep {
  const factory NavigationStep({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'patient_id') required String patientId,
    @HiveField(2) required String destination,
    @HiveField(3) @JsonKey(name: 'destination_type') required String destinationType, // Lab, X-Ray, Pharmacy, OPD
    @HiveField(4) required List<String> directions,
    @HiveField(5) double? latitude,
    @HiveField(6) double? longitude,
    @HiveField(7) @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @HiveField(8) @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _NavigationStep;

  factory NavigationStep.fromJson(Map<String, dynamic> json) => _$NavigationStepFromJson(json);
}




