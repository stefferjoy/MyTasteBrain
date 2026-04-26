import 'package:flutter/foundation.dart';

import '../models/recipe.dart';

/// Central local data store for recipes and ingredients.
///
/// This class holds the user's saved recipes, ingredients at home,
/// and provides recipe suggestions based on what the user has available.
class TasteMemoryModel extends ChangeNotifier {
  final List<Recipe> _savedRecipes = [];
  final List<String> _ingredientsAtHome = [];

  /// An unmodifiable view of the recipes the user has saved.
  List<Recipe> get savedRecipes => List.unmodifiable(_savedRecipes);

  /// An unmodifiable view of the ingredients the user currently has on hand.
  List<String> get ingredientsAtHome => List.unmodifiable(_ingredientsAtHome);

  /// Adds a recipe to the list of saved recipes.
  void addRecipe(Recipe recipe) {
    _savedRecipes.add(recipe);
    notifyListeners();
  }

  /// Adds an ingredient to the list of available ingredients.
  ///
  /// The value is normalized to lower case. Empty and duplicate values are ignored.
  void addIngredient(String ingredient) {
    final normalized = ingredient.trim().toLowerCase();
    if (normalized.isEmpty) return;

    if (!_ingredientsAtHome.contains(normalized)) {
      _ingredientsAtHome.add(normalized);
      notifyListeners();
    }
  }

  /// Removes an ingredient from the list of available ingredients.
  void removeIngredient(String ingredient) {
    _ingredientsAtHome.removeWhere((item) => item == ingredient);
    notifyListeners();
  }

  /// Returns recipes sorted by how many required ingredients are missing.
  ///
  /// Recipes requiring no additional ingredients appear first.
  List<Recipe> suggestRecipes() {
    final sorted = List<Recipe>.from(_savedRecipes);

    sorted.sort((a, b) {
      final missingA = a.missingIngredients(_ingredientsAtHome).length;
      final missingB = b.missingIngredients(_ingredientsAtHome).length;
      return missingA.compareTo(missingB);
    });

    return sorted;
  }
}
