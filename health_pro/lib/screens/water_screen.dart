import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_pro/widgets/hydration_progress.dart';
import 'package:health_pro/widgets/settings_tab.dart';
import 'package:health_pro/widgets/water_volume_selection.dart';
import 'package:intl/intl.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({Key? key}) : super(key: key);

  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double dailyGoal = 2000; // ml
  int reminderInterval = 30; // minutes
  int selectedVolumeIndex = 0;
  double selectedVolume = 250; // ml
  double customVolume = 300; // ml
  bool remindersEnabled = true;
  double currentConsumption = 1290; // ml

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Water',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Drink'),
            Tab(text: 'Analytics'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDrinkTab(),
          _buildAnalyticsTab(),
          SettingsTab(
            dailyGoal: dailyGoal,
            selectedVolume: customVolume,
            reminderInterval: reminderInterval,
            onDailyGoalChanged: (value) {
              setState(() {
                dailyGoal = value;
              });
            },
            onSelectedVolumeChanged: (value) {
              setState(() {
                customVolume = value;
                if (selectedVolumeIndex == 3) {
                  selectedVolume = value;
                }
              });
            },
            onReminderIntervalChanged: (value) {
              setState(() {
                reminderInterval = value;
              });
            },
            onUseRecommendedSettings: _useRecommendedSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          HydrationProgress(
            progress: currentConsumption / dailyGoal,
            currentConsumption: currentConsumption,
            dailyGoal: dailyGoal,
          ),
          const SizedBox(height: 20),
          WaterVolumeSelection(
            selectedVolumeIndex: selectedVolumeIndex,
            customVolume: customVolume.toInt(),
            onVolumeSelected: (index) {
              setState(() {
                selectedVolumeIndex = index;
                selectedVolume = index == 0
                    ? 250
                    : index == 1
                        ? 500
                        : index == 2
                            ? 180
                            : customVolume;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addWater,
            child: Text('Drink ${selectedVolume.toInt()} ml'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: 3000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(1, 1500),
                      const FlSpot(2, 2000),
                      const FlSpot(3, 1800),
                      const FlSpot(4, 2200),
                      const FlSpot(5, 1900),
                      const FlSpot(6, 2100),
                      const FlSpot(7, 2300),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: Colors.blue.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(date),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('E').format(date),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addWater() {
    setState(() {
      currentConsumption += selectedVolume;
    });
  }

  void _useRecommendedSettings() {
    setState(() {
      dailyGoal = 2000;
      customVolume = 300;
      reminderInterval = 30;
      if (selectedVolumeIndex == 3) {
        selectedVolume = customVolume;
      }
    });
  }
}
