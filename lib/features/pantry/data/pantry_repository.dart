import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/pantry_item.dart';

class PantryRepository {
  PantryRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<PantryItem>> getItems() async {
    final db = await _database.database;
    final rows = await db.query('pantry_items', orderBy: 'is_leftover DESC, expiry_date ASC, name ASC');
    return rows.map(PantryItem.fromMap).toList();
  }

  Future<List<PantryItem>> getLeftovers() async {
    final db = await _database.database;
    final rows = await db.query(
      'pantry_items',
      where: 'is_leftover = ?',
      whereArgs: [1],
      orderBy: 'expiry_date ASC, updated_at DESC',
    );
    return rows.map(PantryItem.fromMap).toList();
  }

  Future<PantryItem> insertItem(PantryItem item) async {
    final db = await _database.database;
    final savedItem = item.copyWith(updatedAt: DateTime.now());

    final id = await db.transaction<int>((txn) async {
      final itemId = await txn.insert('pantry_items', savedItem.toMap());
      await txn.insert('user_food_events', {
        'event_type': item.isLeftover ? 'leftover_added' : 'pantry_added',
        'recipe_id': null,
        'pantry_item_id': itemId,
        'note': item.name,
        'created_at': DateTime.now().toIso8601String(),
      });
      return itemId;
    });

    return savedItem.copyWith(id: id);
  }

  Future<void> deleteItem(int id) async {
    final db = await _database.database;
    await db.delete('pantry_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markUsed(PantryItem item) async {
    final id = item.id;
    if (id == null) return;

    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert('user_food_events', {
        'event_type': 'pantry_used',
        'recipe_id': null,
        'pantry_item_id': id,
        'note': item.name,
        'created_at': DateTime.now().toIso8601String(),
      });
      await txn.delete('pantry_items', where: 'id = ?', whereArgs: [id]);
    });
  }
}
