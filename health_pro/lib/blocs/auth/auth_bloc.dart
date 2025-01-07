// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    // Handle Register
    on<RegisterUser>((event, emit) async {
      try {
        emit(AuthLoading());

        final user = await _authRepository.registerUser(
          email: event.email,
          password: event.password,
          name: event.name,
        );

        emit(AuthRegistrationSuccess(user));
      } catch (e) {
        emit(AuthRegistrationError(e.toString()));
      }
    });

    on<LoginUser>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await _authRepository.loginUser(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Handle Reset Error (untuk menghapus state error)
    on<ResetAuthError>((event, emit) {
      emit(AuthInitial());
    });

    // Handle Sign Out
    on<SignOut>((event, emit) async {
      try {
        emit(AuthLoading());
        await _authRepository.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Handle Check Auth Status
    on<CheckAuthStatus>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
