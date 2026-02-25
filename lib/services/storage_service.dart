import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static Database? _database;
  static const String _dbName = 'todo_cache.db';
  static const String _tableName = 'todos';

  static const String _keyServerUrl = 'server_url';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 2, // 升级版本以支持新字段
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            local_id TEXT,
            title TEXT NOT NULL,
            description TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            priority TEXT NOT NULL DEFAULT 'medium',
            category TEXT NOT NULL DEFAULT 'general',
            due_date INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            sync_version INTEGER DEFAULT 1
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN local_id TEXT');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN sync_version INTEGER DEFAULT 1');
        }
      },
    );
  }

  Future<void> cacheTodos(List<Todo> todos) async {
    final db = await database;
    await db.delete(_tableName);
    final batch = db.batch();
    for (final todo in todos) {
      batch.insert(_tableName, todo.toDbMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Todo>> getCachedTodos() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map((map) => Todo.fromDbMap(map)).toList();
  }

  Future<void> cacheTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      _tableName,
      todo.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCachedTodo(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // 同步版本存储
  static const String _keySyncVersion = 'sync_version';
  
  Future<int> getSyncVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySyncVersion) ?? 0;
  }

  Future<void> setSyncVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySyncVersion, version);
  }

  // 待操作队列（离线时存储）
  static const String _keyPendingOps = 'pending_operations';
  
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final opsJson = prefs.getString(_keyPendingOps);
    if (opsJson != null) {
      return List<Map<String, dynamic>>.from(
        (opsJson as List).map((e) => Map<String, dynamic>.from(e as Map))
      );
    }
    return [];
  }

  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final prefs = await SharedPreferences.getInstance();
    final ops = await getPendingOperations();
    ops.add(operation);
    await prefs.setString(_keyPendingOps, jsonEncode(ops));
  }

  Future<void> clearPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingOps);
  }

  Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerUrl);
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, url);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeMode, isDark);
  }

  // Token存储
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // 用户信息存储
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}
