import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/widgets/custom_month_year_picker.dart';
import 'package:intl/intl.dart';

class WaterAnalyticsTab extends StatefulWidget {
  final WaterModel model;
  final DateTime accountCreatedAt; // Tambahkan ini

  const WaterAnalyticsTab(
      {Key? key, required this.model, required this.accountCreatedAt})
      : super(key: key);

  @override
  State<WaterAnalyticsTab> createState() => _WaterAnalyticsTabState();
}

class _WaterAnalyticsTabState extends State<WaterAnalyticsTab> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 24),
        _buildSummaryCard(),
        const SizedBox(height: 24),
        // _buildWeeklyConsumptionCard(),
        _buildAverageDailyPatternCard(),
        const SizedBox(height: 24),
        _buildHourlyConsumptionCard(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Selected Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: _showMonthYearPicker,
              icon: const Icon(Icons.calendar_today, size: 20),
              label: Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    CustomMonthYearPicker.show(
      context,
      initialDate: _selectedDate,
      createdAt: widget.accountCreatedAt, // Use actual account creation date
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildSummaryCard() {
    final averageConsumption = _calculateAverageConsumption();
    final daysAchieved = _calculateDaysAchievedGoal();
    final totalConsumption = _calculateTotalConsumption();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Average Daily',
                    '${averageConsumption.toStringAsFixed(0)} ml',
                    Icons.water_drop,
                    tooltipMessage:
                        'This represents the average daily water consumption for the selected month. It is calculated by dividing the total monthly consumption by the number of days in the month.',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Days Achieved',
                    '$daysAchieved days',
                    Icons.check_circle,
                    tooltipMessage:
                        'This shows the number of days where your water consumption met or exceeded the current daily goal.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              'Total Consumption',
              '${(totalConsumption / 1000).toStringAsFixed(1)} L',
              Icons.water,
              tooltipMessage:
                  'This is the total amount of water consumed during the selected month, in liters.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon,
      {required String tooltipMessage}) {
    return Tooltip(
      message: tooltipMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyConsumptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Consumption',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(_createWeeklyBarData()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyConsumptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hourly Pattern',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Tooltip(
                  message:
                      'This chart shows the average hourly water consumption pattern for the selected month. Each point on the graph represents the amount of water consumed during a specific hour, calculated based on daily consumption data averaged over the month.',
                  child: Icon(Icons.info_outline, size: 20, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(_createHourlyLineData()),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createWeeklyBarData() {
    final weeklyData = _getWeeklyConsumptionData();
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final maxY = (weeklyData.reduce((a, b) => a > b ? a : b).toDouble() * 1.2)
        .clamp(widget.model.dailyGoal.toDouble(), double.infinity);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.round()} ml',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final day = days[value.toInt()];
              final date = startOfWeek.add(Duration(days: value.toInt()));
              final formattedDate = DateFormat('dd').format(date);

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Text(
                      day,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (maxY / 5).clamp(1, double.infinity),
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY / 4).clamp(1, double.infinity),
      ),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: entry.value >= widget.model.dailyGoal
                  ? Colors.blue
                  : Colors.blue.withOpacity(0.5),
              width: 20,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData _createHourlyLineData() {
    final hourlyData = _getHourlyConsumptionData();
    final maxY = hourlyData.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY / 5).clamp(1, double.infinity),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 6,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}:00',
                style: const TextStyle(fontSize: 12),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY / 5)
                .clamp(1, double.infinity), // Ensure interval is non-zero
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: hourlyData
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.blueGrey,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.round()} ml',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
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

  Widget _buildAverageDailyPatternCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Average Daily Pattern',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Tooltip(
                  message:
                      'This chart shows the average daily water consumption pattern for the selected month. Each bar represents the average water consumption for a specific day of the week (e.g., Monday, Tuesday), calculated by averaging the daily consumption recorded for all instances of that day within the selected month.',
                  child: Icon(Icons.info_outline, size: 20, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(_createAverageDailyPatternBarData()),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createAverageDailyPatternBarData() {
    final dailyAverages = _getAverageDailyPattern();
    final maxY = (dailyAverages.reduce((a, b) => a > b ? a : b) * 1.2)
        .clamp(widget.model.dailyGoal.toDouble(), double.infinity);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.round()} ml',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Text(
                days[value.toInt()],
                style: const TextStyle(fontSize: 12),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (maxY / 5).clamp(1, double.infinity),
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY / 4).clamp(1, double.infinity),
      ),
      borderData: FlBorderData(show: false),
      barGroups: dailyAverages.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: entry.value >= widget.model.dailyGoal
                  ? Colors.blue
                  : Colors.blue.withOpacity(0.5),
              width: 20,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<double> _getAverageDailyPattern() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final dailyTotals =
        List.filled(7, 0); // Index 0 = Senin, ..., Index 6 = Minggu
    final dailyCounts = List.filled(7, 0);

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      if (date.isAfter(DateTime.now())) break; // Abaikan tanggal di masa depan

      final weekdayIndex = date.weekday - 1; // Monday = 0, ..., Sunday = 6
      dailyTotals[weekdayIndex] += widget.model.getConsumptionForDate(date);
      dailyCounts[weekdayIndex] += 1;
    }

    // Hitung rata-rata untuk setiap hari
    return List.generate(7, (index) {
      if (dailyCounts[index] == 0) return 0.0; // Hindari pembagian dengan 0
      return dailyTotals[index] / dailyCounts[index];
    });
  }

  double _calculateAverageConsumption() {
    final monthData = _getMonthlyConsumptionData();
    if (monthData.isEmpty) return 0;
    final total = monthData.reduce((a, b) => a + b);
    return total / monthData.length;
  }

  int _calculateDaysAchievedGoal() {
    return _getMonthlyConsumptionData()
        .where((amount) => amount >= widget.model.dailyGoal)
        .length;
  }

  int _calculateTotalConsumption() {
    final monthData = _getMonthlyConsumptionData();
    if (monthData.isEmpty) return 0;
    return monthData.reduce((a, b) => a + b);
  }

  List<int> _getMonthlyConsumptionData() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    return List.generate(daysInMonth, (index) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
      if (date.isAfter(DateTime.now())) return 0;
      return widget.model.getConsumptionForDate(date);
    });
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

    // Average the data by the number of days in the month
    final daysInMonth = monthEnd.day;
    for (var i = 0; i < hourlyData.length; i++) {
      hourlyData[i] = (hourlyData[i] / daysInMonth).round();
    }

    return hourlyData;
  }
}
