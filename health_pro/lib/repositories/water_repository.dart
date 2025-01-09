// water_repository.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_pro/models/water_model.dart';

class WaterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AwesomeNotifications _notifications;

  WaterRepository(this._notifications);

  Future<void> saveWaterModel(WaterModel model) async {
    await _firestore
        .collection('water_tracking')
        .doc(model.userId)
        .set(model.toJson());
  }

  Future<WaterModel?> getWaterModel(String userId) async {
    final doc = await _firestore.collection('water_tracking').doc(userId).get();
    if (!doc.exists) return null;
    return WaterModel.fromJson(doc.data()!);
  }

  Future<void> scheduleReminder(WaterModel model) async {
    try {
      await _notifications.cancelNotificationsByGroupKey('water_reminder');

      // Cek jika reminder diaktifkan di model dan izin notifikasi diberikan
      if (!model.remindersEnabled) return;

      final isAllowed = await _notifications.isNotificationAllowed();
      if (!isAllowed) return; // Skip scheduling jika tidak ada izin

      await _notifications.createNotification(
        content: NotificationContent(
          id: model.userId.hashCode,
          channelKey: 'water_reminder',
          title: 'Time to drink water!',
          body:
              'Stay hydrated - drink ${model.selectedVolume.toInt()}ml of water now',
          notificationLayout: NotificationLayout.Default,
          groupKey: 'water_reminder',
        ),
        schedule: NotificationInterval(
          interval: Duration(minutes: model.reminderInterval),
          repeats: true,
        ),
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      // Error saat menjadwalkan notifikasi tidak akan mengganggu fungsi utama aplikasi
    }
  }
}
