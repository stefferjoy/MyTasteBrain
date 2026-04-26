import '../../../features/pantry/models/pantry_item.dart';
import '../../../features/taste_profile/models/taste_profile.dart';
import '../../../models/recipe.dart';
import '../models/recipe_match.dart';

class RecipeMatcher {
  List<RecipeMatch> match({
    required List<Recipe> recipes,
    required List<PantryItem> pantryItems,
    required TasteProfile tasteProfile,
  }) {
    final pantryNames = pantryItems.map((item) => item.name.trim().toLowerCase()).toSet();
    final leftoverNames = pantryItems
        .where((item) => item.isLeftover)
        .map((item) => item.name.trim().toLowerCase())
        .toSet();
    final expiringNames = pantryItems
        .where((item) => item.isExpiringSoon)
        .map((item) => item.name.trim().toLowerCase())
        .toSet();
    final disliked = tasteProfile.dislikedIngredients.map((item) => item.trim().toLowerCase()).toSet();
    final preferredTags = tasteProfile.preferredTags.map((item) => item.trim().toLowerCase()).toSet();

    final matches = recipes.map((recipe) {
      final recipeIngredients = recipe.ingredients.map((item) => item.trim().toLowerCase()).toSet();
      final available = recipeIngredients.intersection(pantryNames).toList()..sort();
      final missing = recipeIngredients.difference(pantryNames).toList()..sort();
      final leftoversUsed = recipeIngredients.intersection(leftoverNames).toList()..sort();
      final expiringUsed = recipeIngredients.intersection(expiringNames).toList()..sort();
      final dislikedUsed = recipeIngredients.intersection(disliked);
      final preferredTagHits = recipe.tags.map((item) => item.trim().toLowerCase()).toSet().intersection(preferredTags);

      var score = 0;
      score += available.length * 12;
      score -= missing.length * 10;
      score += leftoversUsed.length * 16;
      score += expiringUsed.length * 20;
      score += preferredTagHits.length * 8;
      score += recipe.cookedCount * 4;
      score -= recipe.skippedCount * 5;
      score -= dislikedUsed.length * 40;

      final reasonParts = <String>[];
      if (missing.isEmpty) {
        reasonParts.add('you have everything needed');
      } else if (available.isNotEmpty) {
        reasonParts.add('you already have ${available.join(', ')}');
      }
      if (leftoversUsed.isNotEmpty) {
        reasonParts.add('it uses leftovers: ${leftoversUsed.join(', ')}');
      }
      if (expiringUsed.isNotEmpty) {
        reasonParts.add('it uses items that should be used soon: ${expiringUsed.join(', ')}');
      }
      if (preferredTagHits.isNotEmpty) {
        reasonParts.add('it matches your taste: ${preferredTagHits.join(', ')}');
      }
      if (dislikedUsed.isNotEmpty) {
        reasonParts.add('warning: it includes disliked ingredients: ${dislikedUsed.join(', ')}');
      }

      return RecipeMatch(
        recipe: recipe,
        availableIngredients: available,
        missingIngredients: missing,
        leftoverIngredientsUsed: leftoversUsed,
        expiringIngredientsUsed: expiringUsed,
        score: score,
        reason: reasonParts.isEmpty ? 'saved in your Taste Brain' : reasonParts.join('; '),
      );
    }).toList();

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}
