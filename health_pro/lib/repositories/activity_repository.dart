import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import '../models/step_activity.dart';

class ActivityRepository {
  final DatabaseHelper _databaseHelper;
  final FirebaseFirestore _firestore;
  DateTime? _lastSyncTime;
  static const syncInterval = Duration(milliseconds: 100);
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

      // Tandai aktivitas sebagai sudah disinkronkan di database lokal
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

      // Ambil semua aktivitas yang belum disinkronkan dari database lokal
      final unsyncedActivities = await _databaseHelper.getUnsyncedActivities();

      // Sinkronkan setiap aktivitas yang belum disinkronkan
      for (var activity in unsyncedActivities) {
        await _syncActivity(activity);
      }

      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error syncing activities: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<StepActivity>> getAllActivities(String userId) async {
    // Implementasi untuk mengambil semua aktivitas dari Firestore atau local database
    // Contoh untuk Firestore:
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      final activitiesData = snapshot.data()?['activities'] as List<dynamic>?;
      if (activitiesData != null) {
        return activitiesData
            .map((activity) => StepActivity.fromFirestoreMap(userId, activity))
            .toList();
      }
    }

    return []; // Return empty list jika tidak ada data
  }
}
