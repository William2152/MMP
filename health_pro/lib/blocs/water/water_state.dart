// water_state.dart
part of 'water_bloc.dart';

// @immutable
sealed class WaterState extends Equatable {
  const WaterState();

  @override
  List<Object?> get props => [];
}

final class WaterInitial extends WaterState {
  const WaterInitial();
}

final class WaterLoadingState extends WaterState {
  const WaterLoadingState();
}

final class WaterLoadedState extends WaterState {
  final WaterModel model;

  const WaterLoadedState({required this.model});

  double get todaysConsumption {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return model.dailyConsumption[today] ?? 0;
  }

  bool get goalAchieved => todaysConsumption >= model.dailyGoal;

  @override
  List<Object?> get props => [model, todaysConsumption, goalAchieved];
}

final class WaterErrorState extends WaterState {
  final String message;

  const WaterErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
