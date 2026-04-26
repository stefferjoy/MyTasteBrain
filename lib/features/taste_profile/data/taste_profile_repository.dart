import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/taste_profile.dart';

class TasteProfileRepository {
  TasteProfileRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<TasteProfile> getProfile() async {
    final db = await _database.database;
    final rows = await db.query('taste_profile', where: 'id = ?', whereArgs: [1], limit: 1);

    if (rows.isEmpty) {
      final profile = TasteProfile.empty();
      await saveProfile(profile);
      return profile;
    }

    return TasteProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(TasteProfile profile) async {
    final db = await _database.database;
    await db.insert(
      'taste_profile',
      profile.copyWith(updatedAt: DateTime.now()).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
