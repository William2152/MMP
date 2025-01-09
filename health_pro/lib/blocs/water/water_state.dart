// water_state.dart
// part of 'water_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:health_pro/models/water_model.dart';

// @immutable
sealed class WaterState extends Equatable {
  const WaterState();

  @override
  List<Object?> get props => [];
}

final class WaterInitial extends WaterState {
  const WaterInitial();
}

final class WaterLoadingState extends WaterState {
  const WaterLoadingState();
}

final class WaterLoadedState extends WaterState {
  final WaterModel model;

  const WaterLoadedState({required this.model});

  @override
  List<Object?> get props => [model];
}

final class WaterErrorState extends WaterState {
  final String message;
  const WaterErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
