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

// Event untuk menghapus data lama
class DeleteOldData extends ActivityEvent {}

// Event untuk mengupdate step goal
class UpdateStepGoal extends ActivityEvent {
  final int stepGoal;

  UpdateStepGoal(this.stepGoal);
}

// Event untuk mengupdate step range
class UpdateStepRange extends ActivityEvent {
  final int stepRange;

  UpdateStepRange(this.stepRange);
}
