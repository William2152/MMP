// lib/models/step_activity.dart
import 'package:equatable/equatable.dart';

class StepActivity extends Equatable {
  final String id;
  final String userId;
  final int steps;
  final double distance;
  final double calories;
  final String date;
  final bool isSynced;
  final DateTime lastUpdated;

  const StepActivity({
    required this.id,
    required this.userId,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.date,
    this.isSynced = false,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'date': date,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // New method for Firestore array object
  Map<String, dynamic> toFirestoreMap() {
    return {
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'date': date,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StepActivity.fromMap(Map<String, dynamic> map) {
    return StepActivity(
      id: map['id'],
      userId: map['userId'],
      steps: map['steps'],
      distance: map['distance'],
      calories: map['calories'],
      date: map['date'],
      isSynced: map['isSynced'] == 1,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  // New factory for Firestore array object
  factory StepActivity.fromFirestoreMap(
      String userId, Map<String, dynamic> map) {
    final date = map['date'] as String;
    return StepActivity(
      id: '${userId}_$date',
      userId: userId,
      steps: map['steps'],
      distance: map['distance'],
      calories: map['calories'],
      date: date,
      isSynced: true,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  StepActivity copyWith({
    String? id,
    String? userId,
    int? steps,
    double? distance,
    double? calories,
    String? date,
    bool? isSynced,
    DateTime? lastUpdated,
  }) {
    return StepActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, steps, distance, calories, date, isSynced, lastUpdated];
}
