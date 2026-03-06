import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue_entry.freezed.dart';
part 'queue_entry.g.dart';

@HiveType(typeId: 1)
@freezed
class QueueEntry with _$QueueEntry {
  const factory QueueEntry({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'patient_id') required String patientId,
    @HiveField(2) @JsonKey(name: 'patient_name') required String patientName,
    @HiveField(3) @JsonKey(name: 'patient_phone') required String patientPhone,
    @HiveField(4) @JsonKey(name: 'queue_number') required int queueNumber,
    @HiveField(5) required String room,
    @HiveField(6) @JsonKey(name: 'joined_at') required DateTime joinedAt,
    @HiveField(7) @JsonKey(name: 'called_at') DateTime? calledAt,
    @HiveField(8) @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @HiveField(9) @JsonKey(name: 'current_position') @Default(0) int currentPosition,
    @HiveField(10) @JsonKey(name: 'total_in_queue') @Default(0) int totalInQueue,
  }) = _QueueEntry;

  factory QueueEntry.fromJson(Map<String, dynamic> json) => _$QueueEntryFromJson(json);
}




