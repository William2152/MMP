// lib/services/background_pedometer_service.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:health_pro/models/step_activity.dart';
import 'package:health_pro/repositories/activity_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundPedometerService {
  static const String USER_ID_KEY = 'current_user_id';
  static const String BODY_WEIGHT_KEY = 'body_weight';
  static const String STEP_LENGTH_KEY = 'step_length';
  static const platform = MethodChannel('com.example.health_pro/step_counter');

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: "HealthPro Step Tracker",
        initialNotificationContent: "Tracking steps in background",
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (ServiceInstance service) async {
          await onStart(service);
          return true;
        },
        autoStart: true,
      ),
    );
    service.startService();
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    final prefs = await SharedPreferences.getInstance();
    final repository = ActivityRepository();

    if (service is AndroidServiceInstance) {
      await service.setAsForegroundService();
      await service.setForegroundNotificationInfo(
        title: "HealthPro Step Tracker",
        content: "Tracking your daily steps",
      );
    }

    // Variables untuk tracking
    int lastRecordedSteps = 0;
    DateTime? lastUpdateTime;
    String? currentUserId = prefs.getString(USER_ID_KEY);

    // Periodic step checking
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        currentUserId = prefs.getString(USER_ID_KEY);
        if (currentUserId == null) return;

        // Get steps from native platform
        final int currentSteps = await platform.invokeMethod('getStepCount');

        final now = DateTime.now();
        final today =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        // Initialize if first run of the day
        if (lastUpdateTime?.day != now.day) {
          lastRecordedSteps = 0;
        }

        // Calculate step increment
        final stepIncrement = currentSteps - lastRecordedSteps;
        if (stepIncrement > 0) {
          lastRecordedSteps = currentSteps;
          lastUpdateTime = now;

          // Get weight and step length from SharedPreferences
          final double weight = prefs.getDouble(BODY_WEIGHT_KEY) ??
              70.0; // Default weight 70.0 kg
          final double stepLength = prefs.getDouble(STEP_LENGTH_KEY) ??
              0.78; // Default step length 0.78 meters

          // Calculate metrics
          final distance = (stepIncrement * stepLength) / 1000; // Convert to km

          // Calculate calories using MET
          final double MET = 3.5; // MET value for walking
          final calories = stepIncrement * stepLength * weight * MET / 1000;

          // Update activity
          var activity = await repository.getTodayActivity(currentUserId!);
          final totalSteps = (activity?.steps ?? 0) + stepIncrement;
          final totalDistance = (activity?.distance ?? 0) + distance;
          final totalCalories = (activity?.calories ?? 0) + calories;

          activity = StepActivity(
            id: '${currentUserId!}_$today',
            userId: currentUserId!,
            steps: totalSteps,
            distance: totalDistance,
            calories: totalCalories,
            date: today,
            lastUpdated: now,
            isSynced: false,
          );

          await repository.saveActivity(activity);

          // Update notification
          if (service is AndroidServiceInstance) {
            await service.setForegroundNotificationInfo(
              title: "HealthPro Step Tracker",
              content: "Today's steps: $totalSteps",
            );
          }
        }
      } catch (e) {
        print('Error getting step count: $e');
      }
    });
  }

  static Future<void> updateUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_ID_KEY);
  }

  static Future<void> updateBodyWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(BODY_WEIGHT_KEY, weight);
  }

  static Future<void> updateStepLength(double stepLength) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(STEP_LENGTH_KEY, stepLength);
  }
}
