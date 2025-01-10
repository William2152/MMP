// lib/blocs/activity/activity_event.dart
abstract class ActivityEvent {}

class LoadTodayActivity extends ActivityEvent {}

class UpdateStepCount extends ActivityEvent {
  final int steps;
  final double distance;
  final double calories;

  UpdateStepCount({
    required this.steps,
    required this.distance,
    required this.calories,
  });
}

class SyncActivities extends ActivityEvent {}
