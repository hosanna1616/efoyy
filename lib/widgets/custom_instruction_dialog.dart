import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/models/instruction.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/providers/staff_provider.dart';

class CustomInstructionDialog extends ConsumerStatefulWidget {
  final String? patientId;
  final String? patientPhone;
  final String? patientName;

  const CustomInstructionDialog({
    super.key,
    this.patientId,
    this.patientPhone,
    this.patientName,
  });

  @override
  ConsumerState<CustomInstructionDialog> createState() => _CustomInstructionDialogState();
}

class _CustomInstructionDialogState extends ConsumerState<CustomInstructionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _stepsController = TextEditingController();
  InstructionType _selectedType = InstructionType.general;
  bool _isDrugShortage = false;
  final _alternativeMedicineController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _stepsController.dispose();
    _alternativeMedicineController.dispose();
    super.dispose();
  }

  Future<void> _sendInstruction() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.patientId == null || widget.patientPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final steps = _stepsController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();

      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one instruction step'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isSending = false);
        return;
      }

      final instruction = Instruction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: widget.patientId!,
        type: _selectedType,
        title: _titleController.text.trim(),
        steps: steps,
        createdAt: DateTime.now(),
        unavailableMedicine: _isDrugShortage ? _titleController.text.trim() : null,
        alternativeMedicine: _isDrugShortage && _alternativeMedicineController.text.trim().isNotEmpty
            ? _alternativeMedicineController.text.trim()
            : null,
      );

      // Save locally
      await HiveService.saveInstruction(instruction);

      // Send SMS
      final stepsText = instruction.steps
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');
      
      String smsMessage = '${instruction.title}\n\n$stepsText';
      if (_isDrugShortage && instruction.unavailableMedicine != null && instruction.alternativeMedicine != null) {
        smsMessage += '\n\nመድሃኒት ${instruction.unavailableMedicine} የለም – ተተኪ ${instruction.alternativeMedicine} ይጠቀሙ';
      }
      
      await SMSService.sendSMS(
        phoneNumber: widget.patientPhone!,
        message: smsMessage,
      );

      // Send to Supabase
      try {
        await SupabaseService.createInstruction(instruction);
      } catch (e) {
        print('Failed to sync instruction to backend: $e');
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Instruction sent to ${widget.patientName ?? "patient"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffAuthProvider);
    
    return AlertDialog(
      title: const Text('Write Custom Instruction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.patientName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Chip(
                    avatar: const Icon(Icons.person),
                    label: Text('To: ${widget.patientName}'),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Medication Instructions',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<InstructionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: InstructionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (one per line)',
                  hintText: '1. First instruction\n2. Second instruction\n3. Third instruction',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Medicine Not Available'),
                value: _isDrugShortage,
                onChanged: (value) {
                  setState(() => _isDrugShortage = value ?? false);
                },
              ),
              if (_isDrugShortage) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alternativeMedicineController,
                  decoration: const InputDecoration(
                    labelText: 'Alternative Medicine',
                    hintText: 'Enter alternative medicine name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendInstruction,
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}

