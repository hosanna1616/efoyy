import 'package:freezed_annotation/freezed_annotation.dart';

part 'hospital_location.freezed.dart';
part 'hospital_location.g.dart';

@freezed
class HospitalLocation with _$HospitalLocation {
  const factory HospitalLocation({
    required String id,
    required String name,
    required String type, // OPD, Lab, Pharmacy, X-Ray
    required String building,
    required String floor,
    required String room,
    required double latitude,
    required double longitude,
    required List<String> directions,
  }) = _HospitalLocation;

  factory HospitalLocation.fromJson(Map<String, dynamic> json) => _$HospitalLocationFromJson(json);
}





