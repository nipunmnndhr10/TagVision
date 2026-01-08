// db_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _database;

  static const String dbName = 'gallery.db';
  static const String tableName = 'photos';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Insert new photo path
  Future<int> insertPhoto(String path) async {
    final db = await database;
    return await db.insert(tableName, {
      'path': path,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all photos sorted by newest first
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final db = await database;
    return await db.query(tableName, orderBy: 'created_at DESC');
  }
}
