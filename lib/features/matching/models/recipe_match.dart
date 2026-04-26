import '../../../models/recipe.dart';

class RecipeMatch {
  final Recipe recipe;
  final List<String> availableIngredients;
  final List<String> missingIngredients;
  final List<String> leftoverIngredientsUsed;
  final List<String> expiringIngredientsUsed;
  final int score;
  final String reason;

  const RecipeMatch({
    required this.recipe,
    required this.availableIngredients,
    required this.missingIngredients,
    required this.leftoverIngredientsUsed,
    required this.expiringIngredientsUsed,
    required this.score,
    required this.reason,
  });

  bool get canCookNow => missingIngredients.isEmpty;
  bool get usesLeftovers => leftoverIngredientsUsed.isNotEmpty;
  bool get usesExpiringItems => expiringIngredientsUsed.isNotEmpty;
}
