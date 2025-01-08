// /lib/screens/water_reminder_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/water_old/water_state_old.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'dart:math' as math;
import '../blocs/water_old/water_bloc_old.dart';
import '../blocs/water_old/water_event_old.dart';
// import '../models/water_settings_model.dart';
import '../models/water_consumption_model.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  _WaterReminderScreenState createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedVolumeIndex = 1;
  int customVolume = 250;
  int reminderInterval = 30;

  final List<Map<String, dynamic>> volumeOptions = [
    {
      'volume': 250,
      'icon': Icons.water_drop,
      'type': 'water',
      'label': 'Water'
    },
    {
      'volume': 500,
      'icon': Icons.local_drink,
      'type': 'bottle',
      'label': 'Bottle'
    },
    {'volume': 180, 'icon': Icons.coffee, 'type': 'cup', 'label': 'Cup'},
    {'volume': 250, 'icon': Icons.blender, 'type': 'custom', 'label': 'Custom'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load initial data
    context.read<WaterBloc>().add(LoadWaterSettings());
    // context.read<WaterBloc>().add(LoadTodayConsumption());
    // Load weekly history
    final now = DateTime.now();
    context.read<WaterBloc>().add(FetchWaterHistory(
          startDate: now.subtract(const Duration(days: 7)),
          endDate: now,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaterBloc, WaterState>(
      listener: (context, state) {
        if (state is WaterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is WaterLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Water Reminder',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayView(state),
              _buildAnalyticsView(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayView(WaterState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Hydration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            if (state is WaterConsumptionLoaded)
              _buildHydrationProgress(state)
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 40),
            _buildVolumeSelection(),
            const SizedBox(height: 40),
            _buildReminderSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsView(WaterState state) {
    if (state is WaterHistoryLoaded) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                _createLineChartData(state.history),
              ),
            ),
            const SizedBox(height: 20),
            _buildWeeklyStats(state.history),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildHydrationProgress(WaterConsumptionLoaded state) {
    final percentage =
        state.goal > 0 ? (state.consumption / state.goal) * 100 : 0.0;
    return Center(
      child: SizedBox(
        height: 240,
        width: 200,
        child: LiquidCustomProgressIndicator(
          direction: Axis.vertical,
          value: percentage.clamp(0, 100) / 100,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${state.consumption.toStringAsFixed(0)} ml',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              if (state.consumption == 0)
                const Text(
                  'Start drinking water!',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                )
              else
                Text(
                  '-${(state.goal - state.consumption).toStringAsFixed(0)} ml',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
            ],
          ),
          shapePath: _buildWaterDropPath(const Size(200, 240)),
          backgroundColor: Colors.blue.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
        ),
      ),
    );
  }

  // Previous methods remain the same: _buildWaterDropPath, _buildVolumeSelection, etc.
  Path _buildWaterDropPath(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height) // Start at the bottom center
      ..cubicTo(
        size.width * 0.999, // Control point 1 (bottom-right curve)
        size.height * 0.99,
        size.width, // Control point 2 (right side curve)
        size.height * 0.7,
        size.width / 2, // End point (top center)
        0,
      )
      ..cubicTo(
        0, // Control point 1 (left side curve)
        size.height * 0.7,
        size.width * 0.001, // Control point 2 (bottom-left curve)
        size.height * 0.99,
        size.width / 2, // End point (back to bottom center)
        size.height,
      )
      ..close();
    return path;
  }

  Widget _buildVolumeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Volume',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: volumeOptions.length,
          itemBuilder: (context, index) => _buildVolumeCard(index),
        ),
      ],
    );
  }

  Widget _buildVolumeCard(int index) {
    final isSelected = selectedVolumeIndex == index;
    final isCustom = index == volumeOptions.length - 1;

    return GestureDetector(
      onTap: () {
        if (isCustom) {
          _showCustomVolumeDialog();
        } else {
          setState(() {
            selectedVolumeIndex = index;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    volumeOptions[index]['icon'],
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isCustom ? customVolume : volumeOptions[index]['volume']} ml',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    volumeOptions[index]['label'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
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
                // Updated number sequence: 120 -> 10 -> 20 -> etc
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
                    _updateReminderFromGesture(details.localPosition);
                  },
                  onTapDown: (details) {
                    _updateReminderFromGesture(details.localPosition);
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                Transform.rotate(
                  angle: (2 * math.pi * reminderInterval / 120) - 1.575,
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
                          '$reminderInterval',
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

// Fixed gesture calculation
  void _updateReminderFromGesture(Offset position) {
    final center = Offset(150, 150);
    var angle = math.atan2(
      position.dx - center.dx,
      center.dy - position.dy,
    );

    // Normalize angle to 0-2π range
    if (angle < 0) angle += 2 * math.pi;

    // Convert angle to reminder interval (0-120 range)
    setState(() {
      reminderInterval = ((angle / (2 * math.pi)) * 120).round().clamp(1, 120);
    });
  }

  void _showCustomVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempVolume = customVolume;
        return AlertDialog(
          title: const Text('Set Custom Volume'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Volume (ml)',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                tempVolume = int.parse(value).clamp(1, 2000);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customVolume = tempVolume;
                  selectedVolumeIndex = volumeOptions.length - 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
                reminderInterval = newValue;
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

  // Add new methods for analytics functionality
  LineChartData _createLineChartData(List<WaterConsumptionModel> history) {
    // Group consumption by day
    final Map<DateTime, double> dailyConsumption = {};
    for (var consumption in history) {
      final date = DateTime(
        consumption.timestamp.year,
        consumption.timestamp.month,
        consumption.timestamp.day,
      );
      dailyConsumption[date] =
          (dailyConsumption[date] ?? 0) + consumption.amount;
    }

    final spots = dailyConsumption.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(
                '${date.day}/${date.month}',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}ml',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  Widget _buildWeeklyStats(List<WaterConsumptionModel> history) {
    double totalConsumption = 0;
    double averageConsumption = 0;
    double bestDay = 0;

    // Calculate statistics
    if (history.isNotEmpty) {
      totalConsumption = history.fold(0, (sum, item) => sum + item.amount);
      averageConsumption = totalConsumption / 7;

      // Group by day to find best day
      final Map<DateTime, double> dailyConsumption = {};
      for (var consumption in history) {
        final date = DateTime(
          consumption.timestamp.year,
          consumption.timestamp.month,
          consumption.timestamp.day,
        );
        dailyConsumption[date] =
            (dailyConsumption[date] ?? 0) + consumption.amount;
      }
      bestDay = dailyConsumption.values.reduce(math.max);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow('Total Consumption',
                '${totalConsumption.toStringAsFixed(0)} ml'),
            _buildStatRow(
                'Daily Average', '${averageConsumption.toStringAsFixed(0)} ml'),
            _buildStatRow('Best Day', '${bestDay.toStringAsFixed(0)} ml'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
