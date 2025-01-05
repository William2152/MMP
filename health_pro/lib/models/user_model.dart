// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String name;
  final double? weight;
  final double? height;
  final int? age;
  final Map<String, dynamic>? healthData; // Untuk menyimpan data kesehatan user
  final Map<String, dynamic>? preferences; // Untuk menyimpan preferensi user
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.weight,
    this.height,
    this.age,
    this.healthData,
    this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'healthData': healthData,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      healthData: json['healthData'],
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Create copy of model with some updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    double? height,
    double? weight,
    int? age,
    Map<String, dynamic>? healthData,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      healthData: healthData ?? this.healthData,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
