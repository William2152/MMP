// water_event.dart part

import 'package:equatable/equatable.dart';

// @immutable
sealed class WaterEvent extends Equatable {
  const WaterEvent();

  @override
  List<Object?> get props => [];
}

final class LoadWaterDataEvent extends WaterEvent {
  final String userId;
  const LoadWaterDataEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class DrinkWaterEvent extends WaterEvent {
  final int amount;
  const DrinkWaterEvent({required this.amount});

  @override
  List<Object?> get props => [amount];
}

final class UpdateSettingsEvent extends WaterEvent {
  final int? dailyGoal;
  final int? reminderInterval;
  final int? selectedVolume;
  final int? customVolume;
  final bool? remindersEnabled;

  const UpdateSettingsEvent({
    this.dailyGoal,
    this.reminderInterval,
    this.selectedVolume,
    this.customVolume,
    this.remindersEnabled,
  });

  @override
  List<Object?> get props => [
        dailyGoal,
        reminderInterval,
        selectedVolume,
        customVolume,
        remindersEnabled,
      ];
}

final class UpdateVolumeSelectionEvent extends WaterEvent {
  final int index;
  const UpdateVolumeSelectionEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class UseRecommendedSettingsEvent extends WaterEvent {
  final int weight; // Berat badan dalam kilogram
  final int age; // Usia dalam tahun

  const UseRecommendedSettingsEvent({required this.weight, required this.age});
}
