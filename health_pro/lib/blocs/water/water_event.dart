// water_event.dart
part of 'water_bloc.dart';

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

final class UpdateWaterSettingsEvent extends WaterEvent {
  final double? dailyGoal;
  final int? reminderInterval;
  final double? selectedVolume;
  final double? customVolume;
  final bool? remindersEnabled;

  const UpdateWaterSettingsEvent({
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

final class AddWaterConsumptionEvent extends WaterEvent {
  final double amount;

  const AddWaterConsumptionEvent({required this.amount});

  @override
  List<Object?> get props => [amount];
}
