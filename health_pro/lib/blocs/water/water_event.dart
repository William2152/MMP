// lib/blocs/water/water_event.dart
abstract class WaterEvent {}

class LogWaterConsumption extends WaterEvent {
  final double amount;
  final String type;

  LogWaterConsumption({required this.amount, required this.type});
}

class UpdateDailyGoal extends WaterEvent {
  final double dailyGoal;
  UpdateDailyGoal({required this.dailyGoal});
}

class UpdateReminderInterval extends WaterEvent {
  final int reminderInterval;
  UpdateReminderInterval({required this.reminderInterval});
}

class UpdateSelectedVolume extends WaterEvent {
  final double selectedVolume;
  UpdateSelectedVolume({required this.selectedVolume});
}

class UpdateCustomVolume extends WaterEvent {
  final double customVolume;
  UpdateCustomVolume({required this.customVolume});
}

class UpdateRemindersEnabled extends WaterEvent {
  final bool remindersEnabled;
  UpdateRemindersEnabled({required this.remindersEnabled});
}

class LoadTodayConsumption extends WaterEvent {}

class LoadWaterSettings extends WaterEvent {}

class ToggleReminder extends WaterEvent {
  final bool enabled;

  ToggleReminder({required this.enabled});
}

class UpdatePresetAmount extends WaterEvent {
  final String type;
  final double amount;

  UpdatePresetAmount({required this.type, required this.amount});
}

class FetchWaterHistory extends WaterEvent {
  final DateTime startDate;
  final DateTime endDate;

  FetchWaterHistory({required this.startDate, required this.endDate});
}

class ConfirmWaterIntake extends WaterEvent {
  final String type;

  ConfirmWaterIntake({required this.type});
}

class ResetDailyProgress extends WaterEvent {}
