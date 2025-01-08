// water_model.dart
class WaterModel {
  final String userId;
  // Settings
  final double dailyGoal; // in ml
  final int reminderInterval; // in minutes
  final double selectedVolume; // single drink volume in ml
  // final double customVolume; // custom drink volume in ml
  final bool remindersEnabled;

  // Daily consumption
  final Map<DateTime, double>
      dailyConsumption; // key: date, value: total consumption in ml
  DateTime? lastReminderTime;

  WaterModel({
    required this.userId,
    required this.dailyGoal,
    required this.reminderInterval,
    required this.selectedVolume,
    this.remindersEnabled = true,
    Map<DateTime, double>? dailyConsumption,
    this.lastReminderTime,
  }) : this.dailyConsumption = dailyConsumption ?? {};

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dailyGoal': dailyGoal,
      'reminderInterval': reminderInterval,
      'selectedVolume': selectedVolume,
      'remindersEnabled': remindersEnabled,
      'dailyConsumption': dailyConsumption
          .map((key, value) => MapEntry(key.toIso8601String(), value)),
      'lastReminderTime': lastReminderTime?.toIso8601String(),
    };
  }

  factory WaterModel.fromJson(Map<String, dynamic> json) {
    return WaterModel(
      userId: json['userId'],
      dailyGoal: json['dailyGoal'].toDouble(),
      reminderInterval: json['reminderInterval'],
      selectedVolume: json['selectedVolume'].toDouble(),
      remindersEnabled: json['remindersEnabled'] ?? true,
      dailyConsumption: (json['dailyConsumption'] as Map<String, dynamic>?)
              ?.map((key, value) =>
                  MapEntry(DateTime.parse(key), value.toDouble())) ??
          {},
      lastReminderTime: json['lastReminderTime'] != null
          ? DateTime.parse(json['lastReminderTime'])
          : null,
    );
  }

  WaterModel copyWith({
    String? userId,
    double? dailyGoal,
    int? reminderInterval,
    double? selectedVolume,
    double? customVolume,
    bool? remindersEnabled,
    Map<DateTime, double>? dailyConsumption,
    DateTime? lastReminderTime,
  }) {
    return WaterModel(
      userId: userId ?? this.userId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      selectedVolume: selectedVolume ?? this.selectedVolume,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      dailyConsumption: dailyConsumption ?? this.dailyConsumption,
      lastReminderTime: lastReminderTime ?? this.lastReminderTime,
    );
  }
}
