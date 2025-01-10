// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/step_activity.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'step_activity.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE step_activities(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        steps INTEGER NOT NULL,
        distance REAL NOT NULL,
        calories REAL NOT NULL,
        date TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  Future<StepActivity?> getTodayActivity(String userId) async {
    final db = await database;
    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final List<Map<String, dynamic>> result = await db.query(
      'step_activities',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, dateStr],
    );

    if (result.isEmpty) return null;
    return StepActivity.fromMap(result.first);
  }

  Future<void> updateOrInsertActivity(StepActivity activity) async {
    final db = await database;
    await db.insert(
      'step_activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StepActivity>> getUnsyncedActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'step_activities',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => StepActivity.fromMap(maps[i]));
  }

  Future<int> getLastStepCount(String userId) async {
    final db = await database;
    final result = await db.query(
      'step_activities',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastUpdated DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['steps'] as int;
    }
    return 0;
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'step_activities',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
