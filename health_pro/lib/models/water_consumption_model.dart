class WaterConsumptionModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double amount; // in ml
  final String type; // 'water', 'bottle', 'cup', 'custom'

  WaterConsumptionModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'type': type,
    };
  }

  factory WaterConsumptionModel.fromJson(Map<String, dynamic> json) {
    return WaterConsumptionModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'].toDouble(),
      type: json['type'],
    );
  }
}
