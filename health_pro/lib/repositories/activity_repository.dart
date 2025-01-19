// lib/repositories/activity_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import '../models/step_activity.dart';

class ActivityRepository {
  final DatabaseHelper _databaseHelper;
  final FirebaseFirestore _firestore;
  DateTime? _lastSyncTime;
  static const syncInterval = Duration(minutes: 1);
  bool _isSyncing = false;

  ActivityRepository({
    DatabaseHelper? databaseHelper,
    FirebaseFirestore? firestore,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<StepActivity?> getTodayActivity(String userId) async {
    return await _databaseHelper.getTodayActivity(userId);
  }

  Future<void> saveActivity(StepActivity activity,
      {bool forceSync = false}) async {
    await _databaseHelper.updateOrInsertActivity(activity);

    if (forceSync || (await _shouldSync())) {
      await _syncActivity(activity);
    }
  }

  Future<bool> _shouldSync() async {
    if (_isSyncing) return false;
    if (_lastSyncTime == null) return true;

    return DateTime.now().difference(_lastSyncTime!) >= syncInterval;
  }

  Future<void> _syncActivity(StepActivity activity) async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // Get the reference to the user's document
      final userDocRef =
          _firestore.collection('activities').doc(activity.userId);

      // Get the current activities array or create an empty one
      final docSnapshot = await userDocRef.get();
      List<Map<String, dynamic>> activities = [];

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        activities = List<Map<String, dynamic>>.from(data['activities'] ?? []);
      }

      // Find and update or add the activity for this date
      final activityIndex =
          activities.indexWhere((a) => a['date'] == activity.date);
      final activityMap = activity.toFirestoreMap();

      if (activityIndex >= 0) {
        activities[activityIndex] = activityMap;
      } else {
        activities.add(activityMap);
      }

      // Update the document with the new activities array
      await userDocRef.set({
        'activities': activities,
      }, SetOptions(merge: true));

      await _databaseHelper.markAsSynced(activity.id);
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error syncing activity: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncUnsyncedActivities() async {
    if (_isSyncing || !(await _shouldSync())) return;

    try {
      _isSyncing = true;
      final unsyncedActivities = await _databaseHelper.getUnsyncedActivities();

      // Group activities by userId
      final groupedActivities = <String, List<StepActivity>>{};
      for (var activity in unsyncedActivities) {
        groupedActivities.putIfAbsent(activity.userId, () => []).add(activity);
      }

      // Sync activities for each user
      for (var entry in groupedActivities.entries) {
        final userId = entry.key;
        final activities = entry.value;

        // Get the user document reference
        final userDocRef = _firestore.collection('activities').doc(userId);

        // Get current activities array
        final docSnapshot = await userDocRef.get();
        List<Map<String, dynamic>> firestoreActivities = [];

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          firestoreActivities =
              List<Map<String, dynamic>>.from(data['activities'] ?? []);
        }

        // Update activities
        for (var activity in activities) {
          final activityIndex =
              firestoreActivities.indexWhere((a) => a['date'] == activity.date);
          final activityMap = activity.toFirestoreMap();

          if (activityIndex >= 0) {
            firestoreActivities[activityIndex] = activityMap;
          } else {
            firestoreActivities.add(activityMap);
          }

          await _databaseHelper.markAsSynced(activity.id);
        }

        // Update Firestore document
        await userDocRef.set({
          'activities': firestoreActivities,
        }, SetOptions(merge: true));
      }

      _lastSyncTime = DateTime.now();
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> getLastStepCount(String userId) async {
    return await _databaseHelper.getLastStepCount(userId);
  }
}
