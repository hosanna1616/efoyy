import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/models/instruction.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';

// Real-time stream provider for instructions
final patientInstructionsStreamProvider = StreamProvider.family<List<Instruction>, String>((ref, patientId) async* {
  // First yield offline instructions immediately
  final offlineInstructions = HiveService.getPatientInstructions(patientId);
  yield offlineInstructions;
  
  try {
    // Then yield from Supabase stream for real-time updates
    yield* SupabaseService.watchPatientInstructions(patientId).asyncMap((instructions) async {
      // Save to local cache
      for (final inst in instructions) {
        await HiveService.saveInstruction(inst);
      }
      
      // Merge with offline
      final allInstructions = <String, Instruction>{};
      for (final inst in offlineInstructions) {
        allInstructions[inst.id] = inst;
      }
      for (final inst in instructions) {
        allInstructions[inst.id] = inst;
      }
      
      return allInstructions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }).handleError((error) {
      print('Instructions stream error: $error');
      // Return offline instructions on error
      return offlineInstructions;
    });
  } catch (e) {
    print('Error creating instructions stream: $e');
    yield offlineInstructions;
  }
});

// Fallback FutureProvider for compatibility
final patientInstructionsProvider = FutureProvider.family<List<Instruction>, String>((ref, patientId) async {
  try {
    final instructions = await SupabaseService.getPatientInstructions(patientId);
    // Also load from offline cache
    final offlineInstructions = HiveService.getPatientInstructions(patientId);
    
    // Merge and deduplicate
    final allInstructions = <String, Instruction>{};
    for (final inst in offlineInstructions) {
      allInstructions[inst.id] = inst;
    }
    for (final inst in instructions) {
      allInstructions[inst.id] = inst;
      await HiveService.saveInstruction(inst);
    }
    
    return allInstructions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } catch (e) {
    // Return offline instructions if online fails
    return HiveService.getPatientInstructions(patientId);
  }
});

final createInstructionProvider = FutureProvider.family<Instruction, CreateInstructionParams>((ref, params) async {
  try {
    final instruction = Instruction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: params.patientId,
      type: params.type,
      title: params.title,
      steps: params.steps,
      createdAt: DateTime.now(),
      scheduledFor: params.scheduledFor,
    );
    
    final created = await SupabaseService.createInstruction(instruction);
    await HiveService.saveInstruction(created);
    
    // Send SMS for button phone users
    if (!HiveService.isSmartphone()) {
      await SMSService.sendInstructionSMS(
        phoneNumber: params.patientPhone,
        title: params.title,
        steps: params.steps,
      );
    }
    
    return created;
  } catch (e) {
    // Save offline
    final instruction = Instruction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: params.patientId,
      type: params.type,
      title: params.title,
      steps: params.steps,
      createdAt: DateTime.now(),
      scheduledFor: params.scheduledFor,
    );
    await HiveService.saveInstruction(instruction);
    return instruction;
  }
});

class CreateInstructionParams {
  final String patientId;
  final String patientPhone;
  final InstructionType type;
  final String title;
  final List<String> steps;
  final DateTime? scheduledFor;
  
  CreateInstructionParams({
    required this.patientId,
    required this.patientPhone,
    required this.type,
    required this.title,
    required this.steps,
    this.scheduledFor,
  });
}




