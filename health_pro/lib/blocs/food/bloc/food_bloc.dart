import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FirebaseFirestore firestore;

  FoodBloc(this.firestore) : super(FoodInitialState()) {
    on<SaveSelectedFoodsEvent>((event, emit) async {
      emit(FoodSavingState());
      try {
        final collection = firestore.collection('calorie_food_tracking');
        await collection.add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'foods': event.selectedFoods,
          'category': event.category, // Tambahkan kategori global
          'timestamp': FieldValue.serverTimestamp(), // Tambahkan timestamp
        });

        emit(FoodSavedState());
      } catch (e) {
        emit(FoodSaveErrorState(e.toString()));
      }
    });
  }
}
