import 'package:flutter/services.dart';

import '../matching/models/recipe_match.dart';
import 'models/ai_suggestion.dart';

/// Local AI service boundary for Gemma 3 1B via MediaPipe.
///
/// The Flutter app should call this service instead of talking directly to
/// MediaPipe APIs. Native Android/iOS code can implement the platform channel
/// later without changing the app screens or repositories.
class LocalAiService {
  static const MethodChannel _channel = MethodChannel('my_taste_brain/local_ai');

  Future<bool> isAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('isAvailable');
      return available ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<AiSuggestion> rewriteSavedRecipeText(String rawText) async {
    final fallback = _fallbackCleanRecipe(rawText);

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'rewriteRecipeText',
        {'rawText': rawText},
      );

      if (result == null) return fallback;
      return AiSuggestion(
        title: result['title'] as String? ?? 'Clean recipe',
        body: result['body'] as String? ?? fallback.body,
        tags: (result['tags'] as List<Object?>? ?? const []).map((tag) => tag.toString()).toList(),
        generatedOnDevice: true,
      );
    } on MissingPluginException {
      return fallback;
    }
  }

  Future<AiSuggestion> explainRecipeMatch(RecipeMatch match) async {
    final fallback = AiSuggestion(
      title: 'Why this recipe',
      body: match.reason,
      tags: match.recipe.tags,
    );

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'explainRecipeMatch',
        {
          'recipeTitle': match.recipe.title,
          'availableIngredients': match.availableIngredients,
          'missingIngredients': match.missingIngredients,
          'reason': match.reason,
        },
      );

      if (result == null) return fallback;
      return AiSuggestion(
        title: result['title'] as String? ?? fallback.title,
        body: result['body'] as String? ?? fallback.body,
        tags: (result['tags'] as List<Object?>? ?? const []).map((tag) => tag.toString()).toList(),
        generatedOnDevice: true,
      );
    } on MissingPluginException {
      return fallback;
    }
  }

  AiSuggestion _fallbackCleanRecipe(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return AiSuggestion(
      title: 'Clean recipe draft',
      body: lines.isEmpty ? 'Paste recipe text to clean it.' : lines.join('\n'),
      tags: const ['local-fallback'],
    );
  }
}
