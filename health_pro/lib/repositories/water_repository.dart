// water_repository.dart
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_pro/models/water_model.dart';

class WaterRepository {
  final FirebaseFirestore _firestore;
  final AwesomeNotifications _notifications;

  WaterRepository(this._firestore, this._notifications);

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
    if (!model.remindersEnabled) {
      await cancelReminders(model.userId);
      return;
    }

    await _notifications.createNotification(
      content: NotificationContent(
        id: model.userId.hashCode,
        channelKey: 'water_reminder',
        title: 'Time to drink water!',
        body: 'Stay hydrated - drink ${model.selectedVolume}ml of water now',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationInterval(
        interval: Duration(
            seconds: model.reminderInterval * 60), // Convert to seconds
        repeats: true,
      ),
    );
  }

  Future<void> cancelReminders(String userId) async {
    await _notifications.cancelNotificationsByGroupKey('water_reminder');
  }
}
