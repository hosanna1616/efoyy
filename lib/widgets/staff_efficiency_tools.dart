import 'package:flutter/material.dart';
import 'package:efoy/services/sms_service.dart';
import 'package:efoy/services/hive_service.dart';
import 'package:efoy/services/supabase_service.dart';
import 'package:efoy/models/instruction.dart';
import 'package:efoy/widgets/custom_instruction_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffEfficiencyTools extends ConsumerStatefulWidget {
  final String? selectedPatientId;
  final String? selectedPatientPhone;

  const StaffEfficiencyTools({
    super.key,
    this.selectedPatientId,
    this.selectedPatientPhone,
  });

  @override
  ConsumerState<StaffEfficiencyTools> createState() => _StaffEfficiencyToolsState();
}

class _StaffEfficiencyToolsState extends ConsumerState<StaffEfficiencyTools> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() => _searchQuery = query);
    
    if (query.length >= 2) {
      _searchPatients(query);
    } else {
      setState(() => _searchResults = []);
    }
  }

  Future<void> _searchPatients(String query) async {
    setState(() => _isSearching = true);
    try {
      // Try Supabase first
      List<dynamic> supabasePatients = [];
      try {
        final patients = await SupabaseService.searchPatients(query);
        supabasePatients = patients.map((p) => {
          'id': p.id,
          'name': p.name,
          'phone': p.phoneNumber,
        }).toList();
      } catch (e) {
        print('Supabase search error: $e');
      }
      
      // Also search local Hive
      final allPatients = HiveService.getAllPatients();
      final localResults = allPatients
          .where((p) => 
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.phoneNumber.contains(query) ||
              p.id.toLowerCase().contains(query.toLowerCase()))
          .map((p) => {
            'id': p.id,
            'name': p.name,
            'phone': p.phoneNumber,
          })
          .toList();
      
      // Combine and remove duplicates
      final combined = <String, Map<String, dynamic>>{};
      for (var patient in [...supabasePatients, ...localResults]) {
        final id = patient['id'] as String;
        if (!combined.containsKey(id)) {
          combined[id] = patient;
        }
      }
      
      setState(() {
        _searchResults = combined.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  // Common instruction templates
  final List<Map<String, dynamic>> _commonInstructions = [
    {
      'title': 'Fasting before surgery',
      'steps': [
        'Do not eat or drink anything after midnight',
        'Take only prescribed medications with small sips of water',
        'Arrive at hospital 2 hours before surgery',
      ],
      'type': InstructionType.preOp,
    },
    {
      'title': 'Wound care',
      'steps': [
        'Keep wound clean and dry',
        'Change dressing daily',
        'Watch for signs of infection (redness, swelling, pus)',
        'Contact doctor if wound looks infected',
      ],
      'type': InstructionType.postOp,
    },
    {
      'title': 'Take medicine 3 times/day',
      'steps': [
        'Take medicine after meals',
        'Take at 8 AM, 2 PM, and 8 PM',
        'Complete full course even if feeling better',
        'Do not skip doses',
      ],
      'type': InstructionType.general,
    },
  ];

  String? _selectedPatientId;
  String? _selectedPatientPhone;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _selectPatient(Map<String, dynamic> patient) {
    setState(() {
      _selectedPatientId = patient['id'] as String;
      _selectedPatientPhone = patient['phone'] as String;
      _searchQuery = '';
      _searchResults = [];
    });
    _searchController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${patient['name']} (${patient['phone']})'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _sendCommonInstruction(Map<String, dynamic> template) async {
    // Use selected patient or widget's selected patient
    final patientId = _selectedPatientId ?? widget.selectedPatientId;
    final patientPhone = _selectedPatientPhone ?? widget.selectedPatientPhone;
    
    if (patientId == null || patientPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient first from search results'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final instruction = Instruction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        type: template['type'] as InstructionType,
        title: template['title'] as String,
        steps: (template['steps'] as List).cast<String>(),
        createdAt: DateTime.now(),
      );

      // Save locally
      await HiveService.saveInstruction(instruction);

      // Send SMS
      final stepsText = instruction.steps
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');
      await SMSService.sendSMS(
        phoneNumber: patientPhone,
        message: '${instruction.title}\n\n$stepsText',
      );

      // Send to Supabase
      try {
        await SupabaseService.createInstruction(instruction);
      } catch (e) {
        print('Failed to sync instruction to backend: $e');
        // Continue anyway - data is saved locally
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Instruction "${instruction.title}" sent!'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Patient (Name, Phone, ID)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
            ),
          ),
          
          // Selected Patient Display
          if (_selectedPatientId != null)
            Builder(
              builder: (context) {
                final selectedPatient = _searchResults.firstWhere(
                  (p) => p['id'] == _selectedPatientId,
                  orElse: () => {'name': 'Selected Patient', 'phone': _selectedPatientPhone ?? ''},
                );
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected: ${selectedPatient['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedPatientId = null;
                            _selectedPatientPhone = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          
          // Search Results
          if (_searchResults.isNotEmpty && _selectedPatientId == null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final patient = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(patient['name']),
                    subtitle: Text('${patient['phone']} • ${patient['id']}'),
                    onTap: () => _selectPatient(patient),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 20),

        // Common Instructions
        Text(
          'Quick Send Instructions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        // Write Custom Instruction Button
        ElevatedButton.icon(
          onPressed: () {
            final patientId = _selectedPatientId ?? widget.selectedPatientId;
            final patientPhone = _selectedPatientPhone ?? widget.selectedPatientPhone;
            
            if (patientId == null || patientPhone == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a patient first'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            showDialog(
              context: context,
              builder: (context) => CustomInstructionDialog(
                patientId: patientId,
                patientPhone: patientPhone,
                patientName: _searchResults.firstWhere(
                  (p) => p['id'] == patientId,
                  orElse: () => {'name': 'Patient'},
                )['name'] as String?,
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Write Custom Instruction'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ..._commonInstructions.map((template) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _sendCommonInstruction(template),
                icon: const Icon(Icons.send),
                label: Text(template['title'] as String),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
              ),
            )),
      ],
    );
  }
}

