// lib/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistrationSuccess extends AuthState {
  final UserModel user;

  const AuthRegistrationSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class WeightUpdateSuccess extends AuthState {}

class WeightUpdateError extends AuthState {
  final String message;

  const WeightUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class HeightUpdateSuccess extends AuthState {}

class HeightUpdateError extends AuthState {
  final String message;

  const HeightUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class UserDataIncomplete extends AuthState {}

class UserDataComplete extends AuthState {}

class AuthRegistrationError extends AuthState {
  final String message;

  const AuthRegistrationError(this.message);

  @override
  List<Object> get props => [message];
}
