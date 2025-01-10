import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/repositories/water_repository.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WaterRepository waterRepository;

  AuthRepository({required this.waterRepository});

  // Register User
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required int age,
    required double weight,
    required double height,
  }) async {
    try {
      // Step 1: Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Update display name
      await userCredential.user?.updateDisplayName(name);

      // Step 3: Create UserModel with required fields
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        age: age,
        weight: weight,
        height: height,
        createdAt: DateTime.now(),
      );

      // Step 4: Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson())
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: Failed to save user data');
        },
      );

      // Step 5: Save water settings with personalized goal
      final defaultWaterModel = WaterModel(
        userId: user.id,
        dailyGoal: _calculateWaterGoal(weight, age),
        reminderInterval: 30,
        selectedVolume: 250,
        customVolume: 300,
        selectedVolumeIndex: 0,
        remindersEnabled: true,
      );

      await waterRepository.saveWaterModel(defaultWaterModel);
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('An account already exists for that email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception(
              'An error occurred during registration: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Calculate daily water goal based on weight and age
  int _calculateWaterGoal(double? weight, int? age) {
    if (weight == null) {
      return 2000; // Default goal if no weight provided
    }

    // Basic calculation: 30-35ml per kg of body weight
    // Adjust based on age if available
    double multiplier = 33; // Default multiplier
    if (age != null) {
      if (age < 30) {
        multiplier = 35;
      } else if (age > 55) {
        multiplier = 30;
      }
    }

    return (weight * multiplier).round();
  }

  // login user
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        throw 'User data not found';
      }

      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password';
      }
      throw e.message ?? 'Login failed';
    } catch (e) {
      throw 'Login failed: $e';
    }
  }

  // Get Current User with Firestore Data
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Get additional user data from Firestore
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        } else {
          // Return basic user data if Firestore document doesn't exist
          return UserModel(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName ?? '',
            createdAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
