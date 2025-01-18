part of 'food_bloc.dart';

abstract class FoodEvent {}

class SaveSelectedFoodsEvent extends FoodEvent {
  final List<Map<String, dynamic>> selectedFoods;
  final String category;

  SaveSelectedFoodsEvent(this.selectedFoods, this.category);
}
