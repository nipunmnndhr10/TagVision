import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
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

  static const int currentDbVersion = 3; // ← increased version to add user_id

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
            tag TEXT,
            user_id TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // older code path: ensure tag exists (defensive)
          try {
            await db.execute('ALTER TABLE $tableName ADD COLUMN tag TEXT');
          } catch (_) {}
        }
        if (oldVersion < 3) {
          // add user_id column for migration
          try {
            await db.execute('ALTER TABLE $tableName ADD COLUMN user_id TEXT');
          } catch (_) {}
        }
      },
    );
  }

  // ─── CRUD Operations ─────────────────────────────────────────────

  Future<int> insertPhoto(
    String filePath, {
    String? initialTag,
    required String userId,
  }) async {
    final db = await database;
    final int photoId = await db.insert(tableName, {
      'file_path': filePath,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'tag': initialTag, // will be null for now, can be updated later
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return photoId;
  }

  Future<List<Map<String, dynamic>>> getAllPhotos({
    required String userId,
  }) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update tag for a specific photo
  Future<void> updatePhotoTag(
    int id,
    String? newTag, {
    required String userId,
  }) async {
    final db = await database;
    await db.update(
      tableName,
      {'tag': newTag},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> deletePhoto(int id, {required String userId}) async {
    final db = _database;
    await db?.delete(
      tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
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

  // Future<void> insertTags(List<ImageLabel> labels) async{
  //   final db = _database;
  //   await db.update(
  //     tableName,
  //     {'tag': newTag},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );

  // }
}
