import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project_model.dart';

/// خدمة قاعدة البيانات - SQLite
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _database;

  static const String _dbName = 'video_translate_ai.db';
  static const int _dbVersion = 1;
  static const String _projectsTable = 'projects';

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_projectsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        video_path TEXT NOT NULL,
        video_name TEXT NOT NULL,
        video_size_mb REAL NOT NULL,
        video_duration_seconds INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        source_language TEXT NOT NULL DEFAULT 'ar',
        target_language TEXT NOT NULL DEFAULT 'en',
        original_text TEXT DEFAULT '',
        translated_text TEXT DEFAULT '',
        progress_percent REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        thumbnail_path TEXT,
        audio_path TEXT,
        is_starred INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // للترقيات المستقبلية
  }

  Database get _db {
    if (_database == null) throw Exception('Database not initialized');
    return _database!;
  }

  Future<List<ProjectModel>> getAllProjects() async {
    final maps = await _db.query(_projectsTable, orderBy: 'created_at DESC');
    return maps.map(ProjectModel.fromMap).toList();
  }

  Future<ProjectModel?> getProjectById(String id) async {
    final maps = await _db.query(
      _projectsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProjectModel.fromMap(maps.first);
  }

  Future<void> insertProject(ProjectModel project) async {
    await _db.insert(
      _projectsTable,
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProject(ProjectModel project) async {
    await _db.update(
      _projectsTable,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> deleteProject(String id) async {
    await _db.delete(
      _projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllProjects() async {
    await _db.delete(_projectsTable);
  }

  Future<int> getProjectCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_projectsTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
