part of 'food_bloc.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object> get props => [];
}

class FoodInitialState extends FoodState {}

class FoodSavingState extends FoodState {}

class FoodSavedState extends FoodState {}

class FoodSaveErrorState extends FoodState {
  final String message;

  FoodSaveErrorState(this.message);
}

final class FoodInitial extends FoodState {}
