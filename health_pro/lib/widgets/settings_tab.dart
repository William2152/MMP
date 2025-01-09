import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class SettingsTab extends StatefulWidget {
  final int dailyGoal;
  final int selectedVolume;
  final int reminderInterval;
  final Function(Map<String, int>) onSettingsChanged;
  final VoidCallback onUseRecommendedSettings;

  const SettingsTab({
    super.key,
    required this.dailyGoal,
    required this.selectedVolume,
    required this.reminderInterval,
    required this.onSettingsChanged,
    required this.onUseRecommendedSettings,
  });

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // Track both current and initial values
  late int _currentDailyGoal;
  late int _currentSelectedVolume;
  late int _currentReminderInterval;

  late int _initialDailyGoal;
  late int _initialSelectedVolume;
  late int _initialReminderInterval;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void didUpdateWidget(SettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update values if they change from parent
    if (oldWidget.dailyGoal != widget.dailyGoal ||
        oldWidget.selectedVolume != widget.selectedVolume ||
        oldWidget.reminderInterval != widget.reminderInterval) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    _currentDailyGoal = widget.dailyGoal;
    _currentSelectedVolume = widget.selectedVolume;
    _currentReminderInterval = widget.reminderInterval;

    _initialDailyGoal = widget.dailyGoal;
    _initialSelectedVolume = widget.selectedVolume;
    _initialReminderInterval = widget.reminderInterval;
  }

  bool get _hasChanges {
    return _currentDailyGoal != _initialDailyGoal ||
        _currentSelectedVolume != _initialSelectedVolume ||
        _currentReminderInterval != _initialReminderInterval;
  }

  void _saveChanges() {
    final Map<String, int> changes = {};

    if (_currentDailyGoal != _initialDailyGoal) {
      changes['dailyGoal'] = _currentDailyGoal;
    }
    if (_currentSelectedVolume != _initialSelectedVolume) {
      changes['customVolume'] = _currentSelectedVolume;
    }
    if (_currentReminderInterval != _initialReminderInterval) {
      changes['reminderInterval'] = _currentReminderInterval;
    }

    // Call onSettingsChanged with all changes at once
    if (changes.isNotEmpty) {
      widget.onSettingsChanged(changes);
    }

    // Update initial values to match current
    setState(() {
      _initialDailyGoal = _currentDailyGoal;
      _initialSelectedVolume = _currentSelectedVolume;
      _initialReminderInterval = _currentReminderInterval;
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
              onPressed: () {
                widget.onUseRecommendedSettings();
                // Update local values after recommended settings are applied
                setState(() {
                  _initializeValues();
                });
              },
              child: const Text('Use Recommended Settings'),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
        if (_hasChanges)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _saveChanges,
              child: const Icon(Icons.save),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyGoalSetting() {
    // Find initial picker index based on current value
    final initialItem = (_currentDailyGoal ~/ 50) - 10;

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
            scrollController: FixedExtentScrollController(
              initialItem: initialItem.clamp(0, 50),
            ),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() {
                _currentDailyGoal = (index + 10) * 50;
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
          'Custom Water Volume',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _currentSelectedVolume.toDouble(),
          min: 100,
          max: 1000,
          divisions: 90,
          label: '${_currentSelectedVolume.round()} ml',
          onChanged: (value) {
            setState(() {
              _currentSelectedVolume = value.toInt();
            });
          },
        ),
        Text(
          '${_currentSelectedVolume.round()} ml',
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
                  angle: (2 * math.pi * _currentReminderInterval / 120) - 1.575,
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
                          '$_currentReminderInterval',
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

  void _updateIntervalFromGesture(Offset position) {
    final center = Offset(150, 150);
    var angle = math.atan2(
      position.dx - center.dx,
      center.dy - position.dy,
    );

    if (angle < 0) angle += 2 * math.pi;

    setState(() {
      _currentReminderInterval =
          ((angle / (2 * math.pi)) * 120).round().clamp(1, 120);
    });
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
          controller:
              TextEditingController(text: _currentReminderInterval.toString()),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final newValue = int.parse(value).clamp(1, 120);
              setState(() {
                _currentReminderInterval = newValue;
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
