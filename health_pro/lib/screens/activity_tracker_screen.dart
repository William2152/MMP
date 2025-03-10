import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io' show Platform;
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/activity/activity_bloc.dart';
import '../blocs/activity/activity_event.dart';
import '../blocs/activity/activity_state.dart';
import '../repositories/activity_repository.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  _ActivityTrackerScreenState createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen>
    with SingleTickerProviderStateMixin {
  double _stepLength = 0.78;
  double _weight = 70.0;
  int _targetSteps = 10000;
  StreamSubscription<StepCount>? _stepStream;
  late TabController _tabController;
  late ActivityBloc _activityBloc;
  Timer? _syncTimer;

  // Track both device steps and our calculated steps
  int? _deviceInitialSteps;
  int _currentSteps = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _activityBloc = ActivityBloc(
        repository: ActivityRepository(),
        userId: authState.user.id,
      );

      // Load today's activity and initialize current steps
      _activityBloc.add(LoadTodayActivity());
      _initializeCurrentSteps();

      // Set up periodic sync
      _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _activityBloc.add(SyncActivities());
      });
    }

    _requestActivityRecognitionPermission();
  }

  void _initializeCurrentSteps() {
    // Listen for the initial state to set current steps
    final state = _activityBloc.state;
    if (state is ActivityLoaded) {
      _currentSteps = state.activity.steps;
    }

    // Listen for subsequent state changes
    _activityBloc.stream.listen((state) {
      if (state is ActivityLoaded) {
        _currentSteps = state.activity.steps;
      }
    });
  }

  @override
  void dispose() {
    _safelyDisposeStepStream();
    _tabController.dispose();
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        _startTracking();
      } else {
        _showPermissionDeniedDialog(
          isPermanent: status.isPermanentlyDenied,
        );
      }
    } else {
      _startTracking();
    }
  }

  void _showPermissionDeniedDialog({bool isPermanent = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          isPermanent
              ? 'Activity recognition permission is required. Please enable it in settings.'
              : 'Activity recognition permission is required to track your steps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isPermanent) {
                openAppSettings();
              } else {
                _requestActivityRecognitionPermission();
              }
            },
            child: Text(isPermanent ? 'Open Settings' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _safelyDisposeStepStream() async {
    if (_stepStream != null) {
      try {
        await _stepStream?.cancel();
      } catch (e) {
        print('Error disposing step stream: $e');
      }
      _stepStream = null;
    }
  }

  void _startTracking() {
    if (_isTracking) return;

    try {
      _isTracking = true;
      _stepStream = Pedometer.stepCountStream.listen(
        (StepCount event) {
          // Just forward the raw step count to bloc
          // Bloc will handle the incrementing logic
          _activityBloc.add(UpdateStepCount(
            steps: event.steps,
            distance: 0, // Bloc will calculate these
            calories: 0,
          ));
        },
        onError: (error) {
          print('Step tracking error: $error');
          _restartTracking();
        },
      );
    } catch (e) {
      print('Error starting step tracking: $e');
      _isTracking = false;
      _restartTracking();
    }
  }

  void _restartTracking() async {
    await _safelyDisposeStepStream();
    _isTracking = false;

    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      _startTracking();
    }
  }

  double _calculateCalories(int steps) {
    return steps * _weight * 0.0005;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Center(
            child: Text('Please login to track your activity'),
          );
        }

        return BlocProvider.value(
          value: _activityBloc,
          child: BlocConsumer<ActivityBloc, ActivityState>(
            listener: (context, state) {
              if (state is ActivityError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Activity',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Tracker'),
                      Tab(text: 'Settings'),
                    ],
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                  ),
                ),
                body: state is ActivityLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTrackerTab(state),
                          _buildSettingsTab(),
                        ],
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrackerTab(ActivityState state) {
    if (state is! ActivityLoaded) {
      return const Center(child: Text('No activity data available'));
    }

    final activity = state.activity;
    double progress = (activity.steps / _targetSteps) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(260, 260),
                painter: CircleProgressPainter(progress: progress),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${activity.steps} / $_targetSteps',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF98D8AA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoCard(
                title: 'Calories Burned',
                value: '${activity.calories.toStringAsFixed(2)} Kcal',
                icon: Icons.local_fire_department,
              ),
              InfoCard(
                title: 'Distance',
                value: '${activity.distance.toStringAsFixed(2)} km',
                icon: Icons.directions_walk,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step Goal Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Daily Step Goal:',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter step goal',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _targetSteps = int.tryParse(value) ?? 10000;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF98D8AA),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Step goal updated!')),
              );
            },
            child: const Text('Save Step Goal'),
          ),
        ],
      ),
    );
  }
}

// Keeping the existing CircleProgressPainter and InfoCard classes unchanged
class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = const Color(0xFF98D8AA).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF98D8AA), Color(0xFF7CBB9F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final startAngle = -90.0 * 3.14159 / 180;
    final sweepAngle = 2 * 3.14159 * (progress / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
