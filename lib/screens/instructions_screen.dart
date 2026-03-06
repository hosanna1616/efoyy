import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:efoy/providers/patient_provider.dart';
import 'package:efoy/providers/instruction_provider.dart';
import 'package:efoy/models/instruction.dart';
import 'package:efoy/widgets/glassmorphic_card.dart';
import 'package:efoy/widgets/drug_shortage_widget.dart';
import 'package:intl/intl.dart';

class InstructionsScreen extends ConsumerStatefulWidget {
  const InstructionsScreen({super.key});

  @override
  ConsumerState<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends ConsumerState<InstructionsScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('am-ET'); // Amharic
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _tts.speak(text);
      setState(() => _isSpeaking = true);
      _tts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Instructions')),
        body: const Center(
          child: Text('Please register first'),
        ),
      );
    }

    // Use stream provider for real-time updates
    final instructionsAsync = ref.watch(patientInstructionsStreamProvider(patient.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddInstructionDialog(context, patient.id, patient.phoneNumber),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: instructionsAsync.when(
            data: (instructions) {
              if (instructions.isEmpty) {
                return Center(
                  child: GlassmorphicCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No instructions yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: instructions.length,
                itemBuilder: (context, index) {
                  final instruction = instructions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildInstructionCard(context, instruction),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context, Instruction instruction) {
    final isPreOp = instruction.type == InstructionType.preOp;
    final isPostOp = instruction.type == InstructionType.postOp;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPreOp
                      ? Colors.orange.withOpacity(0.2)
                      : isPostOp
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPreOp
                      ? 'Pre-Op'
                      : isPostOp
                          ? 'Post-Op'
                          : 'General',
                  style: TextStyle(
                    color: isPreOp
                        ? Colors.orange
                        : isPostOp
                            ? Colors.blue
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                onPressed: () {
                  final fullText = '${instruction.title}\n${instruction.steps.join('\n')}';
                  _speak(fullText);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            instruction.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...instruction.steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (instruction.scheduledFor != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Scheduled: ${DateFormat('MMM dd, yyyy').format(instruction.scheduledFor!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          // Drug Shortage Warning
          if (instruction.unavailableMedicine != null &&
              instruction.alternativeMedicine != null)
            DrugShortageWidget(
              unavailableMedicine: instruction.unavailableMedicine!,
              alternativeMedicine: instruction.alternativeMedicine!,
              pharmacyLocation: instruction.pharmacyLocation ?? 'Nearest pharmacy',
              patientPhone: '', // Will be passed from parent if needed
            ),
        ],
      ),
    );
  }

  void _showAddInstructionDialog(BuildContext context, String patientId, String phoneNumber) {
    // This would typically be used by admin/staff
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instructions are added by hospital staff after consultation'),
      ),
    );
  }
}


