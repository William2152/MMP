import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/widgets/custom_month_year_picker.dart';
import 'package:intl/intl.dart';

class WaterAnalyticsTab extends StatefulWidget {
  final WaterModel model;

  const WaterAnalyticsTab({Key? key, required this.model}) : super(key: key);

  @override
  _WaterAnalyticsTabState createState() => _WaterAnalyticsTabState();
}

class _WaterAnalyticsTabState extends State<WaterAnalyticsTab> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildWeeklyConsumptionChart(),
                _buildDailyAverageConsumption(),
                _buildHourlyConsumptionChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: _showMonthYearPicker,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    CustomMonthYearPicker.show(
      context,
      initialDate: _selectedDate,
      createdAt:
          DateTime(2024, 1, 1), // Replace with actual account creation date
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildWeeklyConsumptionChart() {
    final weeklyData = _getWeeklyConsumptionData();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Consumption',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: widget.model.dailyGoal.toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final weekDays = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      return Text(weekDays[value.toInt()],
                          style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 500,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text('${value.toInt()}ml',
                          style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: weeklyData
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Theme.of(context).primaryColor,
                            width: 20,
                          )
                        ],
                      ))
                  .toList(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAverageConsumption() {
    final averageConsumption = _calculateAverageConsumption();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Average Consumption',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '${averageConsumption.toStringAsFixed(0)} ml',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyConsumptionChart() {
    final hourlyData = _getHourlyConsumptionData();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hourly Consumption',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}:00',
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}ml',
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: 23,
                minY: 0,
                maxY: hourlyData.isEmpty
                    ? 0
                    : hourlyData
                        .reduce((max, element) => element > max ? element : max)
                        .toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: hourlyData
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                            entry.key.toDouble(), entry.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue.withOpacity(0.1),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getWeeklyConsumptionData() {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return widget.model.getConsumptionForDate(date);
    });
  }

  double _calculateAverageConsumption() {
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final totalConsumption = List.generate(daysInMonth, (index) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
      return widget.model.getConsumptionForDate(date);
    }).reduce((a, b) => a + b);
    return totalConsumption / daysInMonth;
  }

  List<int> _getHourlyConsumptionData() {
    final hourlyData = List.filled(24, 0);
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    for (var log in widget.model.consumptionLogs) {
      if (log.timestamp.isAfter(monthStart) &&
          log.timestamp.isBefore(monthEnd)) {
        hourlyData[log.timestamp.hour] += log.amount;
      }
    }

    return hourlyData;
  }
}
