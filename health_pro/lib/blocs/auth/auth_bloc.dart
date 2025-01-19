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
          gender: event.gender,
        );

        emit(AuthRegistrationSuccess(user));
      } catch (e) {
        emit(AuthRegistrationError(e.toString()));
      }
    });

    // Handle Login
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

    // Handle Reset Error
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

    on<UpdateWeight>((event, emit) async {
      try {
        emit(AuthLoading());

        // Perbarui berat badan pengguna di repository
        await _authRepository.updateWeight(event.weight);

        emit(WeightUpdateSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateHeight>((event, emit) async {
      try {
        emit(AuthLoading());

        // Perbarui tinggi badan pengguna di repository
        await _authRepository.updateHeight(event.height);

        emit(HeightUpdateSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateAge>((event, emit) async {
      try {
        emit(AuthLoading());

        // Perbarui usia pengguna di repository
        await _authRepository.updateAge(event.age);

        emit(AgeUpdateSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckUserData>((event, emit) async {
      try {
        emit(AuthLoading());

        // Memanggil fungsi repository untuk memeriksa data
        final isIncomplete = await _authRepository.isUserDataIncomplete();

        if (isIncomplete) {
          emit(UserDataIncomplete());
        } else {
          final user = await _authRepository.getCurrentUser();
          emit(AuthSuccess(user!));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateUserInformation>((event, emit) async {
      try {
        emit(AuthLoading());

        // Add debug print
        print('Updating gender in bloc: ${event.gender}');

        await _authRepository.updateUserInfo(
          name: event.name,
          email: event.email,
          weight: event.weight,
          height: event.height,
          age: event.age,
          gender: event.gender,
        );

        final updatedUser = await _authRepository.getCurrentUser();
        print(
            'Updated user gender: ${updatedUser?.gender}'); // Check if gender is updated in response

        emit(UserInfoUpdateSuccess());
        emit(AuthSuccess(updatedUser!));
      } catch (e) {
        emit(UserInfoUpdateError(e.toString()));
      }
    });

    on<UpdateGender>((event, emit) async {
      try {
        emit(AuthLoading());

        // Update gender in Firebase
        await _authRepository.updateGender(event.gender);

        final user = await _authRepository.getCurrentUser();
        emit(AuthSuccess(user!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
