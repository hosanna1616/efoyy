import 'package:flutter/material.dart';
import 'package:efoy/services/sms_service.dart';

class DrugShortageWidget extends StatelessWidget {
  final String unavailableMedicine;
  final String alternativeMedicine;
  final String pharmacyLocation;
  final String patientPhone;

  const DrugShortageWidget({
    super.key,
    required this.unavailableMedicine,
    required this.alternativeMedicine,
    required this.pharmacyLocation,
    required this.patientPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Medicine Not Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Medicine "$unavailableMedicine" is not available.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Alternative: $alternativeMedicine',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or go to nearest pharmacy: $pharmacyLocation',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'SMS sent: "መድሃኒት $unavailableMedicine የለም – ተተኪ $alternativeMedicine ይጠቀሙ ወይም ቅርብ ፋርማሲ ይሂዱ: $pharmacyLocation"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
}




