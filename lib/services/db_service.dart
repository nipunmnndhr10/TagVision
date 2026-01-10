import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  // Singleton
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _database;

  static const String dbName = 'gallery.db';
  static const String tableName = 'photos';

  static const int currentDbVersion = 2; // ← increased version

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, dbName);

    return await openDatabase(
      dbPath,
      version: currentDbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            tag TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the new column for users who already have version 1
          await db.execute('ALTER TABLE $tableName ADD COLUMN tag TEXT');
        }
        // You can add more future migrations here (3 → 4, etc.)
      },
    );
  }

  // ─── CRUD Operations ─────────────────────────────────────────────

  Future<void> insertPhoto(String filePath, {String? initialTag}) async {
    final db = await database;
    await db.insert(tableName, {
      'file_path': filePath,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'tag': initialTag, // will be null for now, can be updated later
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final db = await database;
    return await db.query(tableName, orderBy: 'created_at DESC');
  }

  /// Update tag for a specific photo
  Future<void> updatePhotoTag(int id, String? newTag) async {
    final db = await database;
    await db.update(
      tableName,
      {'tag': newTag},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePhoto(int id) async {
    final db = _database;
    await db?.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  Future<String> getPhotosDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos'));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    return photosDir.path;
  }
}
