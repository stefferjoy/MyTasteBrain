import 'package:flutter/foundation.dart';

import '../features/matching/models/recipe_match.dart';
import '../features/matching/services/recipe_matcher.dart';
import '../features/pantry/data/pantry_repository.dart';
import '../features/pantry/models/pantry_item.dart';
import '../features/recipes/data/recipe_repository.dart';
import '../features/taste_profile/data/taste_profile_repository.dart';
import '../features/taste_profile/models/taste_profile.dart';
import '../models/recipe.dart';

/// App-level local food memory model.
///
/// This provider keeps the UI synced with SQLite-backed repositories.
/// The data remains local-first and can later be enhanced by OCR, voice,
/// and on-device AI without changing the main product loop.
class TasteMemoryModel extends ChangeNotifier {
  TasteMemoryModel({
    RecipeRepository? recipeRepository,
    PantryRepository? pantryRepository,
    TasteProfileRepository? tasteProfileRepository,
    RecipeMatcher? recipeMatcher,
  })  : _recipeRepository = recipeRepository ?? RecipeRepository(),
        _pantryRepository = pantryRepository ?? PantryRepository(),
        _tasteProfileRepository = tasteProfileRepository ?? TasteProfileRepository(),
        _recipeMatcher = recipeMatcher ?? RecipeMatcher() {
    load();
  }

  final RecipeRepository _recipeRepository;
  final PantryRepository _pantryRepository;
  final TasteProfileRepository _tasteProfileRepository;
  final RecipeMatcher _recipeMatcher;

  List<Recipe> _savedRecipes = [];
  List<PantryItem> _pantryItems = [];
  TasteProfile _tasteProfile = TasteProfile.empty();
  List<RecipeMatch> _recipeMatches = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TasteProfile get tasteProfile => _tasteProfile;
  List<Recipe> get savedRecipes => List.unmodifiable(_savedRecipes);
  List<PantryItem> get pantryItems => List.unmodifiable(_pantryItems);
  List<RecipeMatch> get recipeMatches => List.unmodifiable(_recipeMatches);

  /// Compatibility getter used by the original UI.
  List<String> get ingredientsAtHome => _pantryItems.map((item) => item.name).toList(growable: false);

  List<PantryItem> get leftovers => _pantryItems.where((item) => item.isLeftover).toList(growable: false);
  List<PantryItem> get expiringSoon => _pantryItems.where((item) => item.isExpiringSoon).toList(growable: false);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasteProfile = await _tasteProfileRepository.getProfile();
      _savedRecipes = await _recipeRepository.getRecipes();
      _pantryItems = await _pantryRepository.getItems();
      _refreshMatches();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTasteProfile(TasteProfile profile) async {
    await _tasteProfileRepository.saveProfile(profile);
    _tasteProfile = profile;
    _refreshMatches();
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipeRepository.insertRecipe(recipe);
    _savedRecipes = await _recipeRepository.getRecipes();
    _refreshMatches();
    notifyListeners();
  }

  Future<void> markRecipeCooked(Recipe recipe) async {
    await _recipeRepository.markCooked(recipe);
    _savedRecipes = await _recipeRepository.getRecipes();
    _refreshMatches();
    notifyListeners();
  }

  Future<void> markRecipeSkipped(Recipe recipe, {String? reason}) async {
    await _recipeRepository.markSkipped(recipe, reason: reason);
    _savedRecipes = await _recipeRepository.getRecipes();
    _refreshMatches();
    notifyListeners();
  }

  /// Adds a simple pantry item from a comma-separated ingredient field.
  Future<void> addIngredient(String ingredient) async {
    final normalized = ingredient.trim().toLowerCase();
    if (normalized.isEmpty) return;

    final alreadyExists = _pantryItems.any((item) => item.name == normalized && !item.isLeftover);
    if (alreadyExists) return;

    await addPantryItem(PantryItem(name: normalized));
  }

  Future<void> addPantryItem(PantryItem item) async {
    await _pantryRepository.insertItem(item);
    _pantryItems = await _pantryRepository.getItems();
    _refreshMatches();
    notifyListeners();
  }

  Future<void> removeIngredient(String ingredient) async {
    final normalized = ingredient.trim().toLowerCase();
    final matchingItems = _pantryItems.where((item) => item.name == normalized).toList();
    if (matchingItems.isEmpty) return;

    final id = matchingItems.first.id;
    if (id == null) return;

    await _pantryRepository.deleteItem(id);
    _pantryItems = await _pantryRepository.getItems();
    _refreshMatches();
    notifyListeners();
  }

  Future<void> markPantryItemUsed(PantryItem item) async {
    await _pantryRepository.markUsed(item);
    _pantryItems = await _pantryRepository.getItems();
    _refreshMatches();
    notifyListeners();
  }

  /// Compatibility method for the original recipe suggestion UI.
  List<Recipe> suggestRecipes() => _recipeMatches.map((match) => match.recipe).toList(growable: false);

  void _refreshMatches() {
    _recipeMatches = _recipeMatcher.match(
      recipes: _savedRecipes,
      pantryItems: _pantryItems,
      tasteProfile: _tasteProfile,
    );
  }
}
