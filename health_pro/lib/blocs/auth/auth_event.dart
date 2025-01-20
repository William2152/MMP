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
  final String gender;

  const RegisterUser({
    required this.email,
    required this.name,
    required this.password,
    required this.gender,
  });

  @override
  List<Object> get props => [email, name, password, gender];
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

class UpdateWeight extends AuthEvent {
  final int weight;

  const UpdateWeight({required this.weight});

  @override
  List<Object> get props => [weight];
}

class UpdateHeight extends AuthEvent {
  final int height;

  const UpdateHeight({required this.height});

  @override
  List<Object> get props => [height];
}

class UpdateAge extends AuthEvent {
  final int age;

  const UpdateAge({required this.age});

  @override
  List<Object> get props => [age];
}

class UpdateGender extends AuthEvent {
  final String gender;

  const UpdateGender({required this.gender});

  @override
  List<Object> get props => [gender];
}

class UpdateUserInformation extends AuthEvent {
  final String name;
  final String email;
  final int weight;
  final int height;
  final int age;
  final String gender;

  const UpdateUserInformation({
    required this.name,
    required this.email,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
  });

  @override
  List<Object> get props => [name, email, weight, height, age, gender];
}

class ResetAuthError extends AuthEvent {}

class CheckUserData extends AuthEvent {}

class SignOut extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
