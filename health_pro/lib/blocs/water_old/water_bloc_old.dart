// lib/blocs/water/water_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/water_old/water_event_old.dart';
import 'package:health_pro/blocs/water_old/water_state_old.dart';
import 'package:health_pro/models/water_settings_model.dart';
import 'package:health_pro/repositories/water_repository_old.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _waterRepository;

  WaterBloc(this._waterRepository) : super(WaterInitial()) {
    on<LogWaterConsumption>(_handleLogWaterConsumption);
    on<LoadWaterSettings>(_handleLoadWaterSettings);
    on<FetchWaterHistory>(_handleFetchWaterHistory);
    on<UpdateDailyGoal>(_handleUpdateDailyGoal);
    on<UpdateReminderInterval>(_handleUpdateReminderInterval);
    on<UpdateSelectedVolume>(_handleUpdateSelectedVolume);
    on<UpdateCustomVolume>(_handleUpdateCustomVolume);
    on<UpdateRemindersEnabled>(_handleUpdateRemindersEnabled);
    on<ConfirmWaterIntake>(_handleConfirmWaterIntake);
  }

  Future<void> _handleLogWaterConsumption(
      LogWaterConsumption event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      await _waterRepository.logWaterConsumption(event.amount, event.type);

      final consumption = await _waterRepository.getTodayConsumption();
      final settings = await _waterRepository.getWaterSettings();

      if (settings != null) {
        emit(WaterConsumptionLoaded(consumption, settings.dailyGoal));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleLoadWaterSettings(
      LoadWaterSettings event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();

      if (settings != null) {
        emit(WaterSettingsLoaded(settings));
      } else {
        final defaultSettings = WaterSettingsModel(
          userId: FirebaseAuth.instance.currentUser!.uid,
          dailyGoal: 2000,
          reminderInterval: 60,
          selectedVolume: 250,
          customVolume: 350,
          remindersEnabled: true,
        );
        await _waterRepository.saveWaterSettings(defaultSettings);
        emit(WaterSettingsLoaded(defaultSettings));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleUpdateDailyGoal(
      UpdateDailyGoal event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();
      if (settings != null) {
        final updatedSettings = WaterSettingsModel(
          userId: settings.userId,
          dailyGoal: event.dailyGoal,
          reminderInterval: settings.reminderInterval,
          selectedVolume: settings.selectedVolume,
          customVolume: settings.customVolume,
          remindersEnabled: settings.remindersEnabled,
        );
        await _waterRepository.saveWaterSettings(updatedSettings);
        emit(WaterSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleUpdateReminderInterval(
      UpdateReminderInterval event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();
      if (settings != null) {
        final updatedSettings = WaterSettingsModel(
          userId: settings.userId,
          dailyGoal: settings.dailyGoal,
          reminderInterval: event.reminderInterval,
          selectedVolume: settings.selectedVolume,
          customVolume: settings.customVolume,
          remindersEnabled: settings.remindersEnabled,
        );
        await _waterRepository.saveWaterSettings(updatedSettings);
        emit(WaterSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleUpdateSelectedVolume(
      UpdateSelectedVolume event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();
      if (settings != null) {
        final updatedSettings = WaterSettingsModel(
          userId: settings.userId,
          dailyGoal: settings.dailyGoal,
          reminderInterval: settings.reminderInterval,
          selectedVolume: event.selectedVolume,
          customVolume: settings.customVolume,
          remindersEnabled: settings.remindersEnabled,
        );
        await _waterRepository.saveWaterSettings(updatedSettings);
        emit(WaterSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleUpdateCustomVolume(
      UpdateCustomVolume event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      await _waterRepository.saveCustomVolume(event.customVolume);
      add(LoadWaterSettings());
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleUpdateRemindersEnabled(
      UpdateRemindersEnabled event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();
      if (settings != null) {
        final updatedSettings = WaterSettingsModel(
          userId: settings.userId,
          dailyGoal: settings.dailyGoal,
          reminderInterval: settings.reminderInterval,
          selectedVolume: settings.selectedVolume,
          customVolume: settings.customVolume,
          remindersEnabled: event.remindersEnabled,
        );
        await _waterRepository.saveWaterSettings(updatedSettings);
        emit(WaterSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleFetchWaterHistory(
      FetchWaterHistory event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final history = await _waterRepository.getConsumptionHistory(
        event.startDate,
        event.endDate,
      );
      emit(WaterHistoryLoaded(history));
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _handleConfirmWaterIntake(
      ConfirmWaterIntake event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final settings = await _waterRepository.getWaterSettings();
      if (settings != null) {
        await _waterRepository.logWaterConsumption(
          settings.selectedVolume,
          event.type,
        );
        final consumption = await _waterRepository.getTodayConsumption();
        emit(WaterConsumptionLoaded(consumption, settings.dailyGoal));
      }
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }
}
