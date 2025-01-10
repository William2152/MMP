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
    // Always get activity from local database
    return await _databaseHelper.getTodayActivity(userId);
  }

  Future<void> saveActivity(StepActivity activity,
      {bool forceSync = false}) async {
    // Always save to local database first
    await _databaseHelper.updateOrInsertActivity(activity);

    // Only sync if connected to internet, enough time has passed, and not currently syncing
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
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .set(activity.toMap());

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

      for (var activity in unsyncedActivities) {
        await _syncActivity(activity);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> getLastStepCount(String userId) async {
    return await _databaseHelper.getLastStepCount(userId);
  }
}
