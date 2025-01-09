// water_model.dart
import 'package:equatable/equatable.dart';

class WaterModel extends Equatable {
  final String userId;
  // Settings
  final int dailyGoal; // in ml
  final int reminderInterval; // in minutes
  final int selectedVolume; // in ml
  final int customVolume; // in ml
  final bool remindersEnabled;
  final int selectedVolumeIndex; // tracks which volume option is selected

  // Consumption logs
  final List<WaterLog> consumptionLogs;
  final DateTime? lastReminderTime;

  const WaterModel({
    required this.userId,
    this.dailyGoal = 2000,
    this.reminderInterval = 30,
    this.selectedVolume = 250,
    this.customVolume = 300,
    this.remindersEnabled = true,
    this.selectedVolumeIndex = 0,
    this.consumptionLogs = const [],
    this.lastReminderTime,
  });

  // Get today's total consumption
  int get todayConsumption {
    final today = DateTime.now();
    return consumptionLogs
        .where((log) =>
            log.timestamp.year == today.year &&
            log.timestamp.month == today.month &&
            log.timestamp.day == today.day)
        .fold(0, (sum, log) => sum + log.amount);
  }

  // Get consumption for a specific date
  int getConsumptionForDate(DateTime date) {
    return consumptionLogs
        .where((log) =>
            log.timestamp.year == date.year &&
            log.timestamp.month == date.month &&
            log.timestamp.day == date.day)
        .fold(0, (sum, log) => (sum + log.amount));
  }

  // Get last 7 days consumption for analytics
  List<int> getLastWeekConsumption() {
    final today = DateTime.now();
    List<int> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      weeklyData.add(getConsumptionForDate(date));
    }

    return weeklyData;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dailyGoal': dailyGoal,
      'reminderInterval': reminderInterval,
      'selectedVolume': selectedVolume,
      'customVolume': customVolume,
      'remindersEnabled': remindersEnabled,
      'selectedVolumeIndex': selectedVolumeIndex,
      'consumptionLogs': consumptionLogs.map((log) => log.toJson()).toList(),
      'lastReminderTime': lastReminderTime?.toIso8601String(),
    };
  }

  factory WaterModel.fromJson(Map<String, dynamic> json) {
    return WaterModel(
      userId: json['userId'] as String,
      dailyGoal: (json['dailyGoal'] as num).toInt(),
      reminderInterval: (json['reminderInterval'] as num).toInt(),
      selectedVolume: (json['selectedVolume'] as num).toInt(),
      customVolume: (json['customVolume'] as num).toInt(),
      remindersEnabled: json['remindersEnabled'] as bool,
      selectedVolumeIndex: (json['selectedVolumeIndex'] as num).toInt(),
      consumptionLogs: (json['consumptionLogs'] as List<dynamic>)
          .map((log) => WaterLog.fromJson(log))
          .toList(),
      lastReminderTime: json['lastReminderTime'] != null
          ? DateTime.parse(json['lastReminderTime'] as String)
          : null,
    );
  }

  WaterModel copyWith({
    String? userId,
    int? dailyGoal,
    int? reminderInterval,
    int? selectedVolume,
    int? customVolume,
    int? selectedVolumeIndex,
    bool? remindersEnabled,
    List<WaterLog>? consumptionLogs,
    DateTime? lastReminderTime,
  }) {
    return WaterModel(
      userId: userId ?? this.userId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      selectedVolume: selectedVolume ?? this.selectedVolume,
      customVolume: customVolume ?? this.customVolume,
      selectedVolumeIndex: selectedVolumeIndex ?? this.selectedVolumeIndex,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      consumptionLogs: consumptionLogs ?? this.consumptionLogs,
      lastReminderTime: lastReminderTime ?? this.lastReminderTime,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        dailyGoal,
        reminderInterval,
        selectedVolume,
        customVolume,
        remindersEnabled,
        selectedVolumeIndex,
        consumptionLogs,
        lastReminderTime,
      ];
}

class WaterLog extends Equatable {
  final String id;
  final DateTime timestamp;
  final int amount;

  const WaterLog({
    required this.id,
    required this.timestamp,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        amount: (json['amount'] as num).toInt(),
      );

  @override
  List<Object?> get props => [id, timestamp, amount];
}
