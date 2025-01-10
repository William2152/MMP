import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/activity/activity_event.dart';
import 'package:health_pro/blocs/activity/activity_state.dart';
import 'package:health_pro/models/step_activity.dart';
import 'package:health_pro/repositories/activity_repository.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _repository;
  final String _userId;
  int _lastDeviceStepCount = 0;
  int _accumulatedSteps = 0;

  ActivityBloc({
    required ActivityRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(ActivityInitial()) {
    on<LoadTodayActivity>(_onLoadTodayActivity);
    on<UpdateStepCount>(_onUpdateStepCount);
    on<SyncActivities>(_onSyncActivities);
  }

  Future<void> _onLoadTodayActivity(
    LoadTodayActivity event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      emit(ActivityLoading());

      // Always load from local database
      final activity = await _repository.getTodayActivity(_userId);
      if (activity != null) {
        _accumulatedSteps = activity.steps;
        emit(ActivityLoaded(activity));
      } else {
        // Create new activity for today
        final today = DateTime.now();
        final dateStr =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        final newActivity = StepActivity(
          id: '${_userId}_$dateStr',
          userId: _userId,
          steps: 0,
          distance: 0.0,
          calories: 0.0,
          date: dateStr,
          lastUpdated: today,
        );
        await _repository.saveActivity(newActivity);
        emit(ActivityLoaded(newActivity));
      }
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onUpdateStepCount(
    UpdateStepCount event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      // If this is the first update
      if (_lastDeviceStepCount == 0) {
        _lastDeviceStepCount = event.steps;
        return;
      }

      // Calculate step increment since last update
      final stepIncrement = event.steps - _lastDeviceStepCount;
      if (stepIncrement <= 0) {
        // Device reset or negative steps, just update last count
        _lastDeviceStepCount = event.steps;
        return;
      }

      // Update last device count
      _lastDeviceStepCount = event.steps;

      // Add increment to accumulated steps
      _accumulatedSteps += stepIncrement;

      final today = DateTime.now();
      final dateStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Calculate new values based on accumulated steps
      final distance =
          (_accumulatedSteps * 0.78) / 1000; // using stepLength 0.78
      final calories = _accumulatedSteps * 70.0 * 0.0005; // using weight 70.0

      final updatedActivity = StepActivity(
        id: '${_userId}_$dateStr',
        userId: _userId,
        steps: _accumulatedSteps,
        distance: distance,
        calories: calories,
        date: dateStr,
        lastUpdated: today,
        isSynced: false,
      );

      // Save to local database first
      await _repository.saveActivity(updatedActivity);
      emit(ActivityLoaded(updatedActivity));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onSyncActivities(
    SyncActivities event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      // Only attempt sync, don't affect local state
      await _repository.syncUnsyncedActivities();
    } catch (e) {
      // Log sync error but don't emit error state
      print('Sync error: $e');
    }
  }
}
