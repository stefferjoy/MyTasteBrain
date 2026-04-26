import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../../../models/recipe.dart';

class RecipeRepository {
  RecipeRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Recipe>> getRecipes() async {
    final db = await _database.database;
    final recipeRows = await db.query('saved_recipes', orderBy: 'updated_at DESC');
    final recipes = <Recipe>[];

    for (final row in recipeRows) {
      final recipeId = row['id'] as int;
      final ingredientRows = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
        orderBy: 'name ASC',
      );
      final ingredients = ingredientRows
          .map((item) => item['name'] as String? ?? '')
          .where((item) => item.trim().isNotEmpty)
          .toList();

      recipes.add(Recipe.fromMap(row, ingredients));
    }

    return recipes;
  }

  Future<Recipe> insertRecipe(Recipe recipe) async {
    final db = await _database.database;
    final savedRecipe = recipe.copyWith(updatedAt: DateTime.now());

    final id = await db.transaction<int>((txn) async {
      final recipeId = await txn.insert('saved_recipes', savedRecipe.toRecipeMap());

      for (final ingredient in recipe.ingredients) {
        final normalized = ingredient.trim().toLowerCase();
        if (normalized.isEmpty) continue;

        await txn.insert('recipe_ingredients', {
          'recipe_id': recipeId,
          'name': normalized,
          'quantity': null,
          'unit': null,
        });
      }

      await txn.insert('user_food_events', {
        'event_type': 'recipe_saved',
        'recipe_id': recipeId,
        'pantry_item_id': null,
        'note': recipe.title,
        'created_at': DateTime.now().toIso8601String(),
      });

      return recipeId;
    });

    return savedRecipe.copyWith(id: id);
  }

  Future<void> markCooked(Recipe recipe) async {
    final id = recipe.id;
    if (id == null) return;

    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.update(
        'saved_recipes',
        {
          'cooked_count': recipe.cookedCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.insert('user_food_events', {
        'event_type': 'recipe_cooked',
        'recipe_id': id,
        'pantry_item_id': null,
        'note': recipe.title,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> markSkipped(Recipe recipe, {String? reason}) async {
    final id = recipe.id;
    if (id == null) return;

    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.update(
        'saved_recipes',
        {
          'skipped_count': recipe.skippedCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.insert('user_food_events', {
        'event_type': 'recipe_skipped',
        'recipe_id': id,
        'pantry_item_id': null,
        'note': reason ?? recipe.title,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }
}
