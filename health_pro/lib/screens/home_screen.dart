import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/auth/auth_bloc.dart';
import 'package:health_pro/blocs/auth/auth_event.dart';
import 'package:health_pro/blocs/auth/auth_state.dart';
import 'package:path/path.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyStats(context), // Today's Progress di atas
                const SizedBox(height: 24),
                _buildFoodLogFocus(context), // Food Log Focus
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodLogFocus(BuildContext context) {
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
                  percent: 0.55,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '656',
                        style: TextStyle(
                          fontSize: 32,
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
  }

  Widget _buildDailyStats(BuildContext context) {
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
                  '8,986',
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
                  '2.5',
                  'glasses',
                  Icons.water_drop,
                  Colors.lightBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
