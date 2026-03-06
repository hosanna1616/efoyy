import 'package:efoy/models/hospital_location.dart';

class HospitalData {
  // Seed data: Generic hospital layout
  static final List<HospitalLocation> locations = [
    HospitalLocation(
      id: 'opd-1',
      name: 'OPD Room 1',
      type: 'OPD',
      building: 'Building A',
      floor: 'Ground Floor',
      room: 'Room 101',
      latitude: 11.5937,
      longitude: 37.3907,
      directions: [
        'ከመግቢያው ውጡ',
        'ቀኝ ዞር',
        '50 ሜትር ይሂዱ',
        'Building A ውስጥ ይግቡ',
        'Ground Floor',
        'Room 101',
      ],
    ),
    HospitalLocation(
      id: 'lab-1',
      name: 'Laboratory',
      type: 'Lab',
      building: 'Building B',
      floor: '1st Floor',
      room: 'Room 201',
      latitude: 11.5940,
      longitude: 37.3910,
      directions: [
        'ከOPD ውጡ',
        'ቀኝ ዞር',
        '100 ሜትር ይሂዱ',
        'Building B ውስጥ ይግቡ',
        'ደረጃ 1 ወደ ላይ',
        'Room 201',
      ],
    ),
    HospitalLocation(
      id: 'xray-1',
      name: 'X-Ray Department',
      type: 'X-Ray',
      building: 'Building B',
      floor: 'Ground Floor',
      room: 'Room 105',
      latitude: 11.5942,
      longitude: 37.3912,
      directions: [
        'ከLab ውጡ',
        'ግራ ዞር',
        '30 ሜትር ይሂዱ',
        'Building B ውስጥ ይግቡ',
        'Ground Floor',
        'Room 105',
      ],
    ),
    HospitalLocation(
      id: 'pharmacy-1',
      name: 'Pharmacy',
      type: 'Pharmacy',
      building: 'Building A',
      floor: 'Ground Floor',
      room: 'Room 110',
      latitude: 11.5935,
      longitude: 37.3905,
      directions: [
        'ከX-Ray ውጡ',
        'ቀኝ ዞር',
        '80 ሜትር ይሂዱ',
        'Building A ውስጥ ይግቡ',
        'Ground Floor',
        'Room 110',
      ],
    ),
  ];
  
  static HospitalLocation getLocationByType(String type) {
    return locations.firstWhere(
      (loc) => loc.type.toLowerCase() == type.toLowerCase(),
      orElse: () => locations.first,
    );
  }
  
  static HospitalLocation? getLocationById(String id) {
    try {
      return locations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }
}





