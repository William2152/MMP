class WaterSettingsModel {
  final String userId;
  final double dailyGoal; // in ml
  final int reminderInterval; // in minutes
  final double selectedVolume; // single drink volume in ml
  double customVolume; // single drink volume in ml
  final bool remindersEnabled;

  WaterSettingsModel({
    required this.userId,
    required this.dailyGoal,
    required this.reminderInterval,
    required this.selectedVolume,
    required this.customVolume,
    required this.remindersEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dailyGoal': dailyGoal,
      'reminderInterval': reminderInterval,
      'selectedVolume': selectedVolume,
      'customVolume': customVolume,
      'remindersEnabled': remindersEnabled,
    };
  }

  factory WaterSettingsModel.fromJson(Map<String, dynamic> json) {
    return WaterSettingsModel(
      userId: json['userId'],
      dailyGoal: json['dailyGoal'].toDouble(),
      reminderInterval: json['reminderInterval'],
      selectedVolume: json['selectedVolume'].toDouble(),
      customVolume: json['customVolume'].toDouble(),
      remindersEnabled: json['remindersEnabled'],
    );
  }
}
