import 'package:flutter/material.dart';
import 'package:health_pro/services/background_pedometer_service.dart';

class SettingsTab extends StatelessWidget {
  final int targetSteps;
  final double stepLength;
  final Function(int) onStepGoalChanged;
  final Function(double) onStepLengthChanged;
  final VoidCallback onSaveSettings;

  const SettingsTab({
    Key? key,
    required this.targetSteps,
    required this.stepLength,
    required this.onStepGoalChanged,
    required this.onStepLengthChanged,
    required this.onSaveSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingSection(
            title: 'Daily Step Goal',
            subtitle: 'Set your daily walking target',
            child: Column(
              children: [
                Text(
                  '$targetSteps steps',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF98D8AA),
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: targetSteps.toDouble(),
                  min: 5000,
                  max: 20000,
                  divisions: 30,
                  label: '$targetSteps steps',
                  onChanged: (value) {
                    onStepGoalChanged(value.round());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('5000'),
                    Text('20000'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingSection(
            title: 'Step Length',
            subtitle:
                'Adjust your average step length for accurate distance calculation',
            child: Column(
              children: [
                Text(
                  '${stepLength.toStringAsFixed(2)} meters',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF98D8AA),
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: stepLength,
                  min: 0.5,
                  max: 1.0,
                  divisions: 50,
                  label: '${stepLength.toStringAsFixed(2)}m',
                  onChanged: (value) {
                    onStepLengthChanged(value);
                    BackgroundPedometerService.updateStepLength(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0.5m'),
                    Text('1.0m'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSaveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
