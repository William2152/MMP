// water_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'water_event.dart';
import 'water_state.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/repositories/water_repository.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository repository;
  String? _currentUserId; // Tambahkan ini untuk tracking

  WaterBloc({required this.repository}) : super(const WaterInitial()) {
    on<LoadWaterDataEvent>(_onLoadWaterData);
    on<DrinkWaterEvent>(_onDrinkWater);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<UpdateVolumeSelectionEvent>(_onUpdateVolumeSelection);
    on<UseRecommendedSettingsEvent>(_onUseRecommendedSettings);
  }

  Future<void> _onLoadWaterData(
      LoadWaterDataEvent event, Emitter<WaterState> emit) async {
    if (_currentUserId == event.userId && state is WaterLoadedState) {
      return; // Skip loading jika data sudah ada untuk user yang sama
    }
    emit(const WaterLoadingState());
    try {
      var model = await repository.getWaterModel(event.userId);
      if (model == null) {
        model = WaterModel(
          userId: event.userId,
          dailyGoal: 2000,
          reminderInterval: 30,
          selectedVolume: 250,
          customVolume: 300,
          selectedVolumeIndex: 0,
          remindersEnabled: true,
        );
        await repository.saveWaterModel(model);
      }
      _currentUserId = event.userId; // Update current userId
      await repository.scheduleReminder(model);
      emit(WaterLoadedState(model: model));
    } catch (e) {
      emit(WaterErrorState(message: e.toString()));
    }
  }

  Future<void> _onDrinkWater(
      DrinkWaterEvent event, Emitter<WaterState> emit) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;
        final newLog = WaterLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          amount: event.amount,
        );

        final updatedModel = currentState.model.copyWith(
          consumptionLogs: [...currentState.model.consumptionLogs, newLog],
          lastReminderTime: DateTime.now(),
        );

        await repository.saveWaterModel(updatedModel);
        await repository.scheduleReminder(updatedModel);
        emit(WaterLoadedState(model: updatedModel));
      } catch (e) {
        emit(WaterErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateSettings(
      UpdateSettingsEvent event, Emitter<WaterState> emit) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;

        // Create updated model with all changes at once
        final updatedModel = currentState.model.copyWith(
          dailyGoal: event.dailyGoal ?? currentState.model.dailyGoal,
          reminderInterval:
              event.reminderInterval ?? currentState.model.reminderInterval,
          customVolume: event.customVolume ?? currentState.model.customVolume,
          selectedVolume:
              event.selectedVolume ?? currentState.model.selectedVolume,
          remindersEnabled:
              event.remindersEnabled ?? currentState.model.remindersEnabled,
        );

        // Save the entire updated model
        await repository.saveWaterModel(updatedModel);
        await repository.scheduleReminder(updatedModel);
        emit(WaterLoadedState(model: updatedModel));
      } catch (e) {
        emit(WaterErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateVolumeSelection(
      UpdateVolumeSelectionEvent event, Emitter<WaterState> emit) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;
        final volumes = [250, 500, 180, currentState.model.customVolume];
        final updatedModel = currentState.model.copyWith(
          selectedVolumeIndex: event.index,
          selectedVolume: volumes[event.index],
        );

        await repository.saveWaterModel(updatedModel);
        emit(WaterLoadedState(model: updatedModel));
      } catch (e) {
        emit(WaterErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onUseRecommendedSettings(
      UseRecommendedSettingsEvent event, Emitter<WaterState> emit) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;

        // Hitung target konsumsi air berdasarkan berat badan dan usia
        final int weight = event.weight; // Berat badan dalam kilogram
        final int age = event.age; // Usia dalam tahun

        int dailyGoal = (weight * 35); // Standar: 30ml per kg berat badan
        if (age < 18) {
          dailyGoal += 500; // Tambah 500 ml untuk remaja
        } else if (age > 55) {
          dailyGoal -= 500; // Kurangi 500 ml untuk usia lanjut
        }

        // Pastikan dailyGoal kelipatan 50
        if (dailyGoal % 50 != 0) {
          dailyGoal =
              (dailyGoal / 50).ceil() * 50; // Pembulatan ke kelipatan 50
        }

        // Perbarui model dengan target yang direkomendasikan
        final updatedModel = currentState.model.copyWith(
          dailyGoal: dailyGoal,
          reminderInterval: 30, // Interval tetap 30 menit
          customVolume: 300, // Volume custom tetap 300 ml
          selectedVolume: currentState.model.selectedVolumeIndex == 3
              ? 300
              : currentState.model.selectedVolume,
        );

        await repository.saveWaterModel(updatedModel);
        await repository.scheduleReminder(updatedModel);
        emit(WaterLoadedState(model: updatedModel));
      } catch (e) {
        emit(WaterErrorState(message: e.toString()));
      }
    }
  }
}
