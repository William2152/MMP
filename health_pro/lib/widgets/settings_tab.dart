import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class SettingsTab extends StatefulWidget {
  final double dailyGoal;
  final double selectedVolume;
  final int reminderInterval;
  final Function(double) onDailyGoalChanged;
  final Function(double) onSelectedVolumeChanged;
  final Function(int) onReminderIntervalChanged;
  final VoidCallback onUseRecommendedSettings;

  const SettingsTab({
    Key? key,
    required this.dailyGoal,
    required this.selectedVolume,
    required this.reminderInterval,
    required this.onDailyGoalChanged,
    required this.onSelectedVolumeChanged,
    required this.onReminderIntervalChanged,
    required this.onUseRecommendedSettings,
  }) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late double _dailyGoal;
  late double _selectedVolume;
  late int _reminderInterval;
  bool _settingsChanged = false;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.dailyGoal;
    _selectedVolume = widget.selectedVolume;
    _reminderInterval = widget.reminderInterval;
  }

  void _updateSettings() {
    widget.onDailyGoalChanged(_dailyGoal);
    widget.onSelectedVolumeChanged(_selectedVolume);
    widget.onReminderIntervalChanged(_reminderInterval);
    setState(() {
      _settingsChanged = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDailyGoalSetting(),
            const SizedBox(height: 24),
            _buildCustomWaterVolumeSetting(),
            const SizedBox(height: 24),
            _buildReminderIntervalSetting(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onUseRecommendedSettings,
              child: const Text('Use Recommended Settings'),
            ),
          ],
        ),
        if (_settingsChanged)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _updateSettings,
              child: const Icon(Icons.save),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyGoalSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Goal',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() {
                _dailyGoal = (index + 10) * 50.0;
                _settingsChanged = true;
              });
            },
            children: List.generate(51, (index) {
              return Center(
                child: Text('${(index + 10) * 50} ml'),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomWaterVolumeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Your Water Volume',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _selectedVolume,
          min: 100,
          max: 1000,
          divisions: 90,
          label: '${_selectedVolume.round()} ml',
          onChanged: (value) {
            setState(() {
              _selectedVolume = value;
              _settingsChanged = true;
            });
          },
        ),
        Text(
          '${_selectedVolume.round()} ml',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReminderIntervalSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Interval',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                ),
                for (int i = 0; i < 12; i++)
                  Transform.rotate(
                    angle: 2 * math.pi * (i / 12),
                    child: Transform.translate(
                      offset: const Offset(0, -130),
                      child: Text(
                        i == 0 ? '120' : '${i * 10}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    _updateIntervalFromGesture(details.localPosition);
                  },
                  onTapDown: (details) {
                    _updateIntervalFromGesture(details.localPosition);
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                Transform.rotate(
                  angle: (2 * math.pi * _reminderInterval / 120) - 1.575,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 140,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade200],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showIntervalPicker,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_reminderInterval',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateVolumeFromGesture(Offset position) {
    final center = Offset(150, 150);
    var angle = math.atan2(
      position.dx - center.dx,
      center.dy - position.dy,
    );

    if (angle < 0) angle += 2 * math.pi;

    setState(() {
      _selectedVolume =
          ((angle / (2 * math.pi)) * 600).round().clamp(50, 500).toDouble();
      _settingsChanged = true;
    });
  }

  void _updateIntervalFromGesture(Offset position) {
    final center = Offset(150, 150);
    var angle = math.atan2(
      position.dx - center.dx,
      center.dy - position.dy,
    );

    if (angle < 0) angle += 2 * math.pi;

    setState(() {
      _reminderInterval = ((angle / (2 * math.pi)) * 120).round().clamp(1, 120);
      _settingsChanged = true;
    });
  }

  void _showVolumePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Water Volume'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Volume (50-500 ml)',
            suffix: Text('ml'),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final newValue = int.parse(value).clamp(50, 500);
              setState(() {
                _selectedVolume = newValue.toDouble();
                _settingsChanged = true;
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder Interval'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes (1-120)',
            suffix: Text('min'),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final newValue = int.parse(value).clamp(1, 120);
              setState(() {
                _reminderInterval = newValue;
                _settingsChanged = true;
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
