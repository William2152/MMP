class MonthlySummary {
  final int totalSteps;
  final double totalDistance;
  final double totalCalories;
  final Map<DateTime, int> dailySteps;
  final Map<DateTime, double> dailyDistance;
  final Map<DateTime, double> dailyCalories;

  MonthlySummary({
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.dailySteps,
    required this.dailyDistance,
    required this.dailyCalories,
  });
}
