import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'instruction.freezed.dart';
part 'instruction.g.dart';

@HiveType(typeId: 2)
enum InstructionType {
  @HiveField(0)
  preOp,
  @HiveField(1)
  postOp,
  @HiveField(2)
  general,
}

@HiveType(typeId: 3)
@freezed
class Instruction with _$Instruction {
  const factory Instruction({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'patient_id') required String patientId,
    @HiveField(2) required InstructionType type,
    @HiveField(3) required String title,
    @HiveField(4) required List<String> steps,
    @HiveField(5) @JsonKey(name: 'created_at') required DateTime createdAt,
    @HiveField(6) @JsonKey(name: 'scheduled_for') DateTime? scheduledFor,
    @HiveField(7) @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @HiveField(8) @JsonKey(name: 'unavailable_medicine') String? unavailableMedicine,
    @HiveField(9) @JsonKey(name: 'alternative_medicine') String? alternativeMedicine,
    @HiveField(10) @JsonKey(name: 'pharmacy_location') String? pharmacyLocation,
  }) = _Instruction;

  factory Instruction.fromJson(Map<String, dynamic> json) => _$InstructionFromJson(json);
}


