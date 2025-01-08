class WaterConsumptionModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double amount; // in ml

  WaterConsumptionModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
    };
  }

  factory WaterConsumptionModel.fromJson(Map<String, dynamic> json) {
    return WaterConsumptionModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'].toDouble(),
    );
  }
}
