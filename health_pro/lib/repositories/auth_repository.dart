import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_pro/models/water_model.dart';
import 'package:health_pro/repositories/water_repository.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WaterRepository waterRepository;

  AuthRepository({required this.waterRepository});

  Future<void> updateUserInfo({
    String? name,
    String? email,
    int? weight,
    int? height,
    int? age,
    String? gender,
  }) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Siapkan data yang akan diperbarui
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) {
        // Perbarui email di Firebase Authentication
        await user.updateEmail(email);
        updateData['email'] = email;
      }
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;

      // Perbarui data di Firestore
      if (updateData.isNotEmpty) {
        await userDoc.update(updateData);
      }
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> setDefaultGender() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists || !userSnapshot.data()!.containsKey('gender')) {
        await userDoc.set({
          'gender': 'not set',
        }, SetOptions(merge: true));
      }
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> updateGender(String gender) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.update({
        'gender': gender,
      });
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> updateHeight(int height) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.update({
        'height': height,
      });
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> updateAge(int age) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.update({
        'age': age,
      });
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> updateWeight(int weight) async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.update({
        'weight': weight,
      });
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<bool> isUserDataIncomplete() async {
    final user = _auth.currentUser;

    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final int weight = data['weight'] ?? 0;
        final int height = data['height'] ?? 0;
        final int age = data['age'] ?? 0;
        final String gender = data['gender'] ?? "not set";

        return weight == 0 || height == 0 || age == 0 || gender == "not set";
      }
    }

    throw Exception("User not logged in or data not found");
  }

  // Register User
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String gender,
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
        age: 0,
        weight: 0,
        height: 0,
        gender: gender,
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
        dailyGoal: 2000,
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
  int _calculateWaterGoal(int weight, int age) {
    int dailyGoal = (weight * 35); // Standar: 30ml per kg berat badan
    if (age < 18) {
      dailyGoal += 500; // Tambah 500 ml untuk remaja
    } else if (age > 55) {
      dailyGoal -= 500; // Kurangi 500 ml untuk usia lanjut
    }

    // Pastikan dailyGoal kelipatan 50
    if (dailyGoal % 50 != 0) {
      dailyGoal =
          ((dailyGoal + 25) / 50).floor() * 50; // Pembulatan ke kelipatan 50
    }
    return dailyGoal;
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
        // Ambil data pengguna dari Firestore
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        } else {
          throw Exception('User data not found in Firestore');
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
