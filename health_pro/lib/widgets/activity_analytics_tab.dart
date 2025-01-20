import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/activity/activity_bloc.dart';
import 'package:health_pro/blocs/activity/activity_state.dart';
import 'package:health_pro/models/step_activity.dart';
import 'package:health_pro/models/step_summary.dart';
import 'package:health_pro/repositories/activity_repository.dart';
import 'package:health_pro/widgets/custom_month_year_picker.dart';
import 'package:intl/intl.dart';

class AnalyticsTab extends StatefulWidget {
  final DateTime userCreatedAt;
  final String userId;

  const AnalyticsTab({
    Key? key,
    required this.userCreatedAt,
    required this.userId,
  }) : super(key: key);

  @override
  _AnalyticsTabState createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  late DateTime _selectedMonth;
  late Future<List<StepActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _activitiesFuture = _loadActivities(); // Memuat data saat initState
  }

  Future<List<StepActivity>> _loadActivities() async {
    final repository = ActivityRepository();
    return await repository.getAllActivities(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StepActivity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No activity data available'));
        }

        final activities = snapshot.data!;
        final monthlySummary =
            _calculateMonthlySummary(activities, _selectedMonth);

        return Column(
          children: [
            // Month Picker
            ListTile(
              title: Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final pickedDate = await CustomMonthYearPicker.show(
                    context,
                    initialDate: _selectedMonth,
                    createdAt: widget.userCreatedAt,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedMonth = date;
                      });
                    },
                  );
                },
              ),
            ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildSummaryCard(
                      'Steps', monthlySummary.totalSteps.toString()),
                  _buildSummaryCard('Distance (km)',
                      monthlySummary.totalDistance.toStringAsFixed(2)),
                  _buildSummaryCard('Calories (cal)',
                      monthlySummary.totalCalories.toStringAsFixed(2)),
                ],
              ),
            ),

            // Charts
            Expanded(
              child: ListView(
                children: [
                  _buildBarChart('Steps', monthlySummary.dailySteps),
                  _buildBarChart('Distance (km)', monthlySummary.dailyDistance),
                  _buildBarChart(
                      'Calories (cal)', monthlySummary.dailyCalories),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, Map<DateTime, num> data) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.info, size: 20),
                  onPressed: () {
                    _showChartInfoDialog(context, title);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  barGroups: data.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key.day,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MonthlySummary _calculateMonthlySummary(
      List<StepActivity> activities, DateTime selectedMonth) {
    int totalSteps = 0;
    double totalDistance = 0.0;
    double totalCalories = 0.0;
    final dailySteps = <DateTime, int>{};
    final dailyDistance = <DateTime, double>{};
    final dailyCalories = <DateTime, double>{};

    for (final activity in activities) {
      final activityDate = DateTime.parse(activity.date);
      if (activityDate.year == selectedMonth.year &&
          activityDate.month == selectedMonth.month) {
        totalSteps += activity.steps;
        totalDistance += activity.distance;
        totalCalories += activity.calories;

        dailySteps[activityDate] =
            (dailySteps[activityDate] ?? 0) + activity.steps;
        dailyDistance[activityDate] =
            (dailyDistance[activityDate] ?? 0) + activity.distance;
        dailyCalories[activityDate] =
            (dailyCalories[activityDate] ?? 0) + activity.calories;
      }
    }

    return MonthlySummary(
      totalSteps: totalSteps,
      totalDistance: totalDistance,
      totalCalories: totalCalories,
      dailySteps: dailySteps,
      dailyDistance: dailyDistance,
      dailyCalories: dailyCalories,
    );
  }
}

void _showChartInfoDialog(BuildContext context, String title) {
  String message = '';
  switch (title) {
    case 'Steps':
      message =
          'This chart shows your daily step count for the selected month. '
          'Each bar represents the total steps taken on that day. '
          'The taller the bar, the more steps you took.';
      break;
    case 'Distance (km)':
      message =
          'This chart shows your daily distance walked or run for the selected month. '
          'Each bar represents the total distance covered on that day. '
          'The taller the bar, the more distance you covered.';
      break;
    case 'Calories (cal)':
      message =
          'This chart shows your daily calories burned for the selected month. '
          'Each bar represents the total calories burned on that day. '
          'The taller the bar, the more calories you burned.';
      break;
    default:
      message =
          'This chart displays your activity data for the selected month.';
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('About $title'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
