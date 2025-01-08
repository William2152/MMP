// water_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/repositories/water_repository.dart';
import 'package:equatable/equatable.dart';

part 'water_event.dart';
part 'water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository repository;

  WaterBloc({required this.repository}) : super(const WaterInitial()) {
    on<LoadWaterDataEvent>(_onLoadWaterData);
    on<UpdateWaterSettingsEvent>(_onUpdateWaterSettings);
    on<AddWaterConsumptionEvent>(_onAddWaterConsumption);
  }

  Future<void> _onLoadWaterData(
    LoadWaterDataEvent event,
    Emitter<WaterState> emit,
  ) async {
    emit(const WaterLoadingState());
    try {
      final model = await repository.getWaterModel(event.userId);
      if (model == null) {
        final defaultModel = WaterModel(
          userId: event.userId,
          dailyGoal: 2000,
          reminderInterval: 60,
          selectedVolume: 250,
          remindersEnabled: true,
        );
        await repository.saveWaterModel(defaultModel);
        await repository.scheduleReminder(defaultModel);
        emit(WaterLoadedState(model: defaultModel));
      } else {
        await repository.scheduleReminder(model);
        emit(WaterLoadedState(model: model));
      }
    } catch (e) {
      emit(WaterErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateWaterSettings(
    UpdateWaterSettingsEvent event,
    Emitter<WaterState> emit,
  ) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;
        final updatedModel = currentState.model.copyWith(
          dailyGoal: event.dailyGoal,
          reminderInterval: event.reminderInterval,
          selectedVolume: event.selectedVolume,
          customVolume: event.customVolume,
          remindersEnabled: event.remindersEnabled,
        );

        await repository.saveWaterModel(updatedModel);
        await repository.scheduleReminder(updatedModel);
        emit(WaterLoadedState(model: updatedModel));
      } catch (e) {
        emit(WaterErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onAddWaterConsumption(
    AddWaterConsumptionEvent event,
    Emitter<WaterState> emit,
  ) async {
    if (state is WaterLoadedState) {
      try {
        final currentState = state as WaterLoadedState;
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        final currentConsumption =
            currentState.model.dailyConsumption[today] ?? 0;
        final updatedConsumption =
            Map<DateTime, double>.from(currentState.model.dailyConsumption);
        updatedConsumption[today] = currentConsumption + event.amount;

        final updatedModel = currentState.model.copyWith(
          dailyConsumption: updatedConsumption,
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
}
