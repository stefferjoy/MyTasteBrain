/// A simple data model representing a recipe.
///
/// It contains a title, a list of ingredients, and optional tags.
/// Tags can describe attributes such as `spicy`, `quick`, `rice bowl`, etc.
class Recipe {
  /// The display name for the recipe.
  final String title;

  /// A list of ingredient names required by this recipe.
  ///
  /// Ingredient names should be lower-case strings, for example:
  /// `rice`, `chicken`, `eggs`.
  final List<String> ingredients;

  /// Optional descriptive tags such as `spicy`, `quick`, or `budget`.
  final List<String> tags;

  Recipe({
    required this.title,
    required this.ingredients,
    this.tags = const [],
  });

  /// Computes which ingredients from this recipe are missing based on
  /// the ingredients the user currently has at home.
  ///
  /// Ingredient comparison is case-insensitive.
  List<String> missingIngredients(List<String> ingredientsAtHome) {
    final lowerHome = ingredientsAtHome.map((e) => e.trim().toLowerCase()).toSet();

    return ingredients
        .where((ingredient) => !lowerHome.contains(ingredient.trim().toLowerCase()))
        .toList();
  }
}
