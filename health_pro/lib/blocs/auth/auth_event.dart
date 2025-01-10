// lib/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterUser extends AuthEvent {
  final String email;
  final String name;
  final String password;
  final int age;
  final double weight;
  final double height;

  const RegisterUser({
    required this.email,
    required this.name,
    required this.password,
    required this.age,
    required this.weight,
    required this.height,
  });

  @override
  List<Object> get props => [email, name, password, age, weight, height];
}

class LoginUser extends AuthEvent {
  final String email;
  final String password;

  const LoginUser({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class ResetAuthError extends AuthEvent {}

class SignOut extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
