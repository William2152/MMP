import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/widgets/activity_analytics_tab.dart';
import 'package:health_pro/widgets/tracker_tab.dart';
import 'package:health_pro/widgets/activity_settings_tab.dart';
import 'package:path/path.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // SharedPreferences keys
  static const String _stepGoalKey = 'step_goal';
  static const String _stepLengthKey = 'step_length';

  int _targetSteps = 10000;
  double _stepLength = 0.78;
  StreamSubscription<StepCount>? _stepStream;
  late TabController _tabController;
  late ActivityBloc _activityBloc;
  Timer? _syncTimer;

  // Track both device steps and our calculated steps
  int _currentSteps = 0;
  bool _isTracking = false;

  late DateTime _userCreatedAt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetSteps = prefs.getInt(_stepGoalKey) ?? 10000;
      _stepLength = prefs.getDouble(_stepLengthKey) ?? 0.78;
    });
  }

  Future<void> _saveSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepGoalKey, _targetSteps);
    await prefs.setDouble(_stepLengthKey, _stepLength);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestActivityRecognitionPermission(
      BuildContext context) async {
    if (mounted) {
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (status.isGranted) {
          _startTracking();
        } else {
          _showPermissionDeniedDialog(
            context,
            isPermanent: status.isPermanentlyDenied,
          );
        }
      } else {
        _startTracking();
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context,
      {bool isPermanent = false}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
                _requestActivityRecognitionPermission(context);
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
          print('Step count updated: ${event.steps}');
          _activityBloc.add(UpdateStepCount(
            steps: event.steps,
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

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _startTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      // Inisialisasi ActivityBloc hanya jika belum diinisialisasi
      _activityBloc = ActivityBloc(
        repository: ActivityRepository(),
        userId: authState.user.id,
      );
      _userCreatedAt = authState.user.createdAt;

      _activityBloc.add(LoadTodayActivity());
      _initializeCurrentSteps();

      _syncTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _activityBloc.add(SyncActivities());
      });

      // Minta izin dan mulai pelacakan
      _requestActivityRecognitionPermission(context);
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        if (authState is! AuthSuccess) {
          return const Center(
            child: Text('Please login to track your activity'),
          );
        }

        return BlocProvider.value(
          value: _activityBloc,
          child: BlocConsumer<ActivityBloc, ActivityState>(
            listener: (BuildContext context, ActivityState state) {
              if (state is ActivityError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (BuildContext context, ActivityState state) {
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
                      Tab(text: 'Analytics'),
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
                          TrackerTab(
                            state: state,
                            targetSteps: _targetSteps,
                          ),
                          AnalyticsTab(
                            userCreatedAt: authState.user.createdAt,
                            userId: authState.user.id,
                          ),
                          SettingsTab(
                            targetSteps: _targetSteps,
                            stepLength: _stepLength,
                            onStepGoalChanged: (value) {
                              setState(() {
                                _targetSteps = value;
                              });
                            },
                            onStepLengthChanged: (value) {
                              setState(() {
                                _stepLength = value;
                              });
                            },
                            onSaveSettings: () => _saveSettings(context),
                          ),
                        ],
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
