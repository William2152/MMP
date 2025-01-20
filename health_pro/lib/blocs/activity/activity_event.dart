// lib/blocs/activity/activity_event.dart
abstract class ActivityEvent {
  const ActivityEvent(); // Tambahkan constructor const
}

class LoadTodayActivity extends ActivityEvent {}

class UpdateStepCount extends ActivityEvent {
  final int steps;
  UpdateStepCount({
    required this.steps,
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

class LoadAllActivities extends ActivityEvent {
  const LoadAllActivities();
}
