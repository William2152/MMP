import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_pro/blocs/auth/auth_bloc.dart';
import 'package:health_pro/blocs/auth/auth_event.dart';
import 'package:health_pro/blocs/auth/auth_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Untuk grafik line chart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(CheckUserData());
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserDataIncomplete) {
            // Redirect to /weight if data is incomplete
            Navigator.pushReplacementNamed(context, '/weight');
          } else if (state is AuthError) {
            // Show error message if any
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              // Tampilkan animasi loading jika state adalah AuthLoading
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green, // Warna animasi loading
                ),
              );
            } else if (state is AuthSuccess) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyStats(context), // Today's Progress di atas
                      const SizedBox(height: 24),
                      _buildFoodLogFocus(
                          context, state.user.caloriesGoal), // Food Log Focus
                      const SizedBox(height: 24),
                      _buildWeeklyCaloriesChart(context), // Grafik line chart
                    ],
                  ),
                ),
              );
            } else if (state is AuthError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const Center(
                child: Text('Unknown state'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFoodLogFocus(BuildContext context, int? caloriesGoal) {
    final userId =
        (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).user.id;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calorie_food_tracking')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalCalories = 0;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final foods = data['foods'] as List<dynamic>;
            for (var food in foods) {
              totalCalories += (food['calories'] as num).toInt();
            }
          }
        }

        final goalCalories = caloriesGoal ?? 2000; // Default goal jika null

        return GestureDetector(
          onTap: () {
            // Navigate to /food_log when tapped
            Navigator.pushReplacementNamed(context, '/food_log');
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Food Log Focus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 12.0,
                      percent: totalCalories / goalCalories,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalCalories / $goalCalories',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Consumed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey[200]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyCaloriesChart(BuildContext context) {
    final userId =
        (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).user.id;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Senin
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Minggu

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calorie_food_tracking')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
          .where('timestamp', isLessThanOrEqualTo: endOfWeek)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Inisialisasi list untuk menyimpan total kalori per hari (Senin-Minggu)
        final weeklyCalories =
            List.filled(7, 0); // Default value [0, 0, 0, 0, 0, 0, 0]

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final dayOfWeek = timestamp.weekday - 1; // 0 = Senin, 6 = Minggu

            // Akumulasi kalori dari array foods
            final foods = data['foods'] as List<dynamic>;
            int totalCalories = 0;
            for (var food in foods) {
              totalCalories += (food['calories'] as num).toInt();
            }

            // Tambahkan total kalori ke hari yang sesuai
            weeklyCalories[dayOfWeek] += totalCalories;
          }
        }

        print("Weekly Calories for Chart: $weeklyCalories");

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: weeklyCalories.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key, // Hari (0 = Senin, 6 = Minggu)
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(), // Total kalori
                              color: Colors.green,
                              width: 16,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              return Text(days[value.toInt()]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // Tambahkan padding atau margin di sini
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 8.0), // Atur padding
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                      fontSize: 12), // Atur ukuran font
                                ),
                              );
                            },
                            reservedSize:
                                40, // Atur lebar reserved space untuk left titles
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyStats(BuildContext context) {
    final userId =
        (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).user.id;
    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    return FutureBuilder(
      future: Future.wait([
        _getTodaySteps(userId, todayDate),
        _getTodayWater(userId, todayDate),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final todaySteps = snapshot.data?[0] ?? 0;
        final todayWater = snapshot.data?[1] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to /activity when tapped
                      Navigator.pushReplacementNamed(context, '/activity');
                    },
                    child: _buildStatCard(
                      'Walk Steps',
                      '$todaySteps',
                      'steps',
                      Icons.directions_walk,
                      Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to /water when tapped
                      Navigator.pushReplacementNamed(context, '/water');
                    },
                    child: _buildStatCard(
                      'Water',
                      '$todayWater',
                      'ml',
                      Icons.water_drop,
                      Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<int> _getTodaySteps(String userId, String todayDate) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .doc(userId)
        .get();
    if (snapshot.exists) {
      final activitiesData = snapshot.data()?['activities'] as List<dynamic>?;
      if (activitiesData != null) {
        for (var activity in activitiesData) {
          if (activity['date'] == todayDate) {
            return activity['steps'] as int;
          }
        }
      }
    }
    return 0;
  }

  Future<int> _getTodayWater(String userId, String todayDate) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('water_tracking')
        .doc(userId)
        .get();
    if (snapshot.exists) {
      final consumptionLogs =
          snapshot.data()?['consumptionLogs'] as List<dynamic>?;
      if (consumptionLogs != null) {
        int totalWater = 0;
        for (var log in consumptionLogs) {
          if (log['timestamp'].toString().startsWith(todayDate)) {
            totalWater += log['amount'] as int;
          }
        }
        return totalWater;
      }
    }
    return 0;
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
