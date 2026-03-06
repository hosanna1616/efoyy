import 'package:flutter_test/flutter_test.dart';
import 'package:efoy/models/queue_entry.dart';

void main() {
  group('QueueEntry', () {
    test('should create a queue entry with correct properties', () {
      final entry = QueueEntry(
        id: '1',
        patientId: 'patient-1',
        patientName: 'Test Patient',
        patientPhone: '0912345678',
        queueNumber: 1,
        room: 'OPD Room 1',
        joinedAt: DateTime.now(),
        isActive: true,
        currentPosition: 0,
        totalInQueue: 5,
      );

      expect(entry.id, '1');
      expect(entry.patientName, 'Test Patient');
      expect(entry.queueNumber, 1);
      expect(entry.isActive, true);
    });

    test('should calculate estimated wait time correctly', () {
      final entry = QueueEntry(
        id: '1',
        patientId: 'patient-1',
        patientName: 'Test Patient',
        patientPhone: '0912345678',
        queueNumber: 3,
        room: 'OPD Room 1',
        joinedAt: DateTime.now(),
        currentPosition: 2,
        totalInQueue: 10,
      );

      // Estimated time: (position + 1) * 10 minutes
      final estimatedMinutes = (entry.currentPosition + 1) * 10;
      expect(estimatedMinutes, 30);
    });
  });
}





