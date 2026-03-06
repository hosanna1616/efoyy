import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@HiveType(typeId: 0)
@freezed
class Patient with _$Patient {
  const factory Patient({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'phone_number') required String phoneNumber,
    @HiveField(2) required String name,
    @HiveField(3) @JsonKey(name: 'photo_url') String? photoUrl,
    @HiveField(4) @JsonKey(name: 'created_at') DateTime? createdAt,
    @HiveField(5) @JsonKey(name: 'last_appointment') DateTime? lastAppointment,
    @HiveField(6) @JsonKey(name: 'next_appointment') DateTime? nextAppointment,
    @HiveField(7) @JsonKey(name: 'next_appointment_room') String? nextAppointmentRoom,
    @HiveField(8) @JsonKey(name: 'medical_history') List<String>? medicalHistory,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}




