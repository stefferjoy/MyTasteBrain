import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// SQLite database wrapper for the local-first MVP.
///
/// All food memory data should stay on the user's device. This database
/// intentionally keeps the schema simple so it can evolve as the MVP grows.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'my_taste_brain.db';
  static const int databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, databaseName);

    _database = await openDatabase(
      fullPath,
      version: databaseVersion,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE taste_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        preferred_cuisines TEXT NOT NULL DEFAULT '',
        preferred_tags TEXT NOT NULL DEFAULT '',
        disliked_ingredients TEXT NOT NULL DEFAULT '',
        spice_level INTEGER NOT NULL DEFAULT 3,
        max_cooking_minutes INTEGER NOT NULL DEFAULT 30,
        budget_level TEXT NOT NULL DEFAULT 'medium',
        diet_notes TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        source_type TEXT NOT NULL DEFAULT 'manual',
        source_url TEXT,
        creator_name TEXT,
        raw_text TEXT,
        summary TEXT,
        steps TEXT NOT NULL DEFAULT '',
        tags TEXT NOT NULL DEFAULT '',
        cooked_count INTEGER NOT NULL DEFAULT 0,
        skipped_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity TEXT,
        unit TEXT,
        FOREIGN KEY (recipe_id) REFERENCES saved_recipes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pantry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'other',
        quantity TEXT,
        unit TEXT,
        expiry_date TEXT,
        storage_location TEXT,
        is_leftover INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_food_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT NOT NULL,
        recipe_id INTEGER,
        pantry_item_id INTEGER,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    final now = DateTime.now().toIso8601String();
    await db.insert('taste_profile', {
      'id': 1,
      'preferred_cuisines': '',
      'preferred_tags': 'quick,budget,home-cooked',
      'disliked_ingredients': '',
      'spice_level': 3,
      'max_cooking_minutes': 30,
      'budget_level': 'medium',
      'diet_notes': '',
      'updated_at': now,
    });
  }
}
