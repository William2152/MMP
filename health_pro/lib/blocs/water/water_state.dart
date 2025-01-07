// lib/blocs/water/water_state.dart
import 'package:health_pro/models/water_consumption_model.dart';
import 'package:health_pro/models/water_settings_model.dart';

abstract class WaterState {}

class WaterInitial extends WaterState {}

class WaterLoading extends WaterState {}

class WaterSettingsLoaded extends WaterState {
  final WaterSettingsModel settings;

  WaterSettingsLoaded(this.settings);
}

class WaterConsumptionLoaded extends WaterState {
  final double consumption;
  final double goal;
  final double percentage;

  WaterConsumptionLoaded(this.consumption, this.goal)
      : percentage = (consumption / goal) * 100;
}

class WaterError extends WaterState {
  final String message;

  WaterError(this.message);
}

class WaterHistoryLoaded extends WaterState {
  final List<WaterConsumptionModel> history;

  WaterHistoryLoaded(this.history);
}
