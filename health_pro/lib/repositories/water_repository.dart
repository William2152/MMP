import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_consumption_model.dart';
import '../models/water_settings_model.dart';

class WaterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logWaterConsumption(double amount, String type) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final consumption = WaterConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      timestamp: DateTime.now(),
      amount: amount,
      type: type,
    );

    await _firestore
        .collection('water_consumption')
        .doc(consumption.id)
        .set(consumption.toJson());
  }

  Future<double> getTodayConsumption() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('water_consumption')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 0.0; // Default to 0 if no consumption data exists
    }
    // Convert each document's 'amount' to double and sum them up
    double total = querySnapshot.docs.fold(0.0, (sum, doc) {
      final data = doc.data();
      return sum +
          (data['amount'] as num).toDouble(); // Explicitly cast to double
    });

    return total;
  }

  Future<void> saveWaterSettings(WaterSettingsModel settings) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('water_settings')
        .doc(user.uid)
        .set(settings.toJson());
  }

  Future<void> saveCustomVolume(double volume) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final settings = await getWaterSettings();
    if (settings != null) {
      settings.customVolume = volume;
      await saveWaterSettings(settings);
    }
  }

  Future<WaterSettingsModel?> getWaterSettings() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('water_settings').doc(user.uid).get();
    return doc.exists ? WaterSettingsModel.fromJson(doc.data()!) : null;
  }

  Future<List<WaterConsumptionModel>> getConsumptionHistory(
      DateTime startDate, DateTime endDate) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('water_consumption')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThan: endDate)
        .orderBy('timestamp')
        .get();

    return querySnapshot.docs
        .map((doc) => WaterConsumptionModel.fromJson(doc.data()))
        .toList();
  }
}
