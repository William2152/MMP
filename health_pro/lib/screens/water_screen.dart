// lib\screens\water_screen.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/auth/auth_bloc.dart';
import 'package:health_pro/blocs/auth/auth_state.dart';
import 'package:health_pro/blocs/water/water_bloc.dart';
import 'package:health_pro/blocs/water/water_event.dart';
import 'package:health_pro/blocs/water/water_state.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/widgets/hydration_progress.dart';
import 'package:health_pro/widgets/settings_tab.dart';
import 'package:health_pro/widgets/water_analytics_tab.dart';
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
  bool _hasCheckedPermissions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeNotifications();

    // Tambahkan ini untuk load data saat pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        context.read<WaterBloc>().add(
              LoadWaterDataEvent(userId: authState.user.id),
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize AwesomeNotifications if not already initialized
      await AwesomeNotifications().initialize(
        null, // no icon for now
        [
          NotificationChannel(
            channelKey: 'water_reminder',
            channelName: 'Water Reminders',
            channelDescription: 'Notifications for water intake reminders',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
          )
        ],
      );

      // Check initial permissions
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      setState(() => _hasCheckedPermissions = true);

      if (!isAllowed) {
        // Show permission request dialog on first launch
        if (mounted) {
          _showNotificationDialog();
        }
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      setState(() => _hasCheckedPermissions = true);
    }
  }

  Future<void> _showNotificationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'To get water intake reminders, please enable notifications. This helps you stay hydrated throughout the day.',
          ),
          actions: [
            TextButton(
              child: const Text('Not Now'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Setting'),
              onPressed: () async {
                AwesomeNotifications().showNotificationConfigPage();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCheckedPermissions) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          return _buildWaterScreen(context);
        }

        if (authState is AuthUnauthenticated) {
          return const Scaffold(
            body: Center(child: Text("Please log in to continue")),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildWaterScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: BlocBuilder<WaterBloc, WaterState>(
        builder: (context, waterState) {
          if (waterState is WaterLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (waterState is WaterErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(waterState.message),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthSuccess) {
                        context.read<WaterBloc>().add(
                              LoadWaterDataEvent(userId: authState.user.id),
                            );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (waterState is WaterLoadedState) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDrinkTab(context, waterState.model),
                _buildAnalyticsTab(context, waterState.model),
                _buildSettingsTab(context, waterState.model),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildDrinkTab(BuildContext context, WaterModel model) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          HydrationProgress(
            progress: model.todayConsumption / model.dailyGoal,
            currentConsumption: model.todayConsumption.toDouble(),
            dailyGoal: model.dailyGoal.toDouble(),
          ),
          const SizedBox(height: 20),
          WaterVolumeSelection(
            selectedVolumeIndex: model.selectedVolumeIndex,
            customVolume: model.customVolume.toInt(),
            onVolumeSelected: (index) {
              context.read<WaterBloc>().add(
                    UpdateVolumeSelectionEvent(index: index),
                  );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<WaterBloc>().add(
                    DrinkWaterEvent(amount: model.selectedVolume),
                  );
            },
            child: Text('Drink ${model.selectedVolume.toInt()} ml'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, WaterModel model) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      return WaterAnalyticsTab(
        model: model,
        accountCreatedAt: authState.user.createdAt, // Pass createdAt ke tab
      );
    }

    return const Center(child: Text("Authentication failed"));
  }

  Widget _buildSettingsTab(BuildContext context, WaterModel model) {
    return SettingsTab(
      dailyGoal: model.dailyGoal,
      selectedVolume: model.customVolume,
      reminderInterval: model.reminderInterval,
      onSettingsChanged: (Map<String, int> changes) {
        context.read<WaterBloc>().add(
              UpdateSettingsEvent(
                dailyGoal: changes['dailyGoal'],
                customVolume: changes['customVolume'],
                reminderInterval: changes['reminderInterval'],
              ),
            );
      },
      onUseRecommendedSettings: () {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthSuccess) {
          context.read<WaterBloc>().add(
                UseRecommendedSettingsEvent(
                  age: authState.user.age,
                  weight: authState.user.weight.toInt(),
                ),
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load user data')),
          );
        }
      },
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
}
