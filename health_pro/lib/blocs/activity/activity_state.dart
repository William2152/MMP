// lib/blocs/activity/activity_state.dart
import 'package:equatable/equatable.dart';
import '../../models/step_activity.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final StepActivity activity;

  const ActivityLoaded(this.activity);

  @override
  List<Object?> get props => [activity];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}
