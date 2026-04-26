import '../../../models/recipe.dart';

/// Lightweight local parser for pasted recipe captions/text.
///
/// This keeps import useful before local AI is fully wired. It is not meant to
/// be perfect; Gemma/MediaPipe can later clean and structure recipes better.
class RecipeTextParser {
  Recipe parse({
    required String rawText,
    String sourceType = 'pasted',
    String? sourceUrl,
    String? creatorName,
  }) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final title = _inferTitle(lines);
    final ingredients = _inferIngredients(lines);
    final tags = _inferTags(rawText);

    return Recipe(
      title: title,
      ingredients: ingredients,
      tags: tags,
      sourceType: sourceType,
      sourceUrl: sourceUrl,
      creatorName: creatorName,
      rawText: rawText,
      steps: lines.join('\n'),
    );
  }

  String _inferTitle(List<String> lines) {
    if (lines.isEmpty) return 'Imported recipe';

    final firstUsefulLine = lines.firstWhere(
      (line) => !line.toLowerCase().startsWith('ingredients'),
      orElse: () => lines.first,
    );

    return firstUsefulLine.length > 64 ? '${firstUsefulLine.substring(0, 61)}...' : firstUsefulLine;
  }

  List<String> _inferIngredients(List<String> lines) {
    final markers = <String>[
      'cup',
      'tbsp',
      'tsp',
      'gram',
      'kg',
      'ml',
      'egg',
      'rice',
      'chicken',
      'onion',
      'garlic',
      'tomato',
      'spinach',
      'yogurt',
      'oil',
      'salt',
      'pepper',
      'cheese',
    ];

    final candidates = <String>{};

    for (final line in lines) {
      final lower = line.toLowerCase();
      final looksLikeIngredient = markers.any(lower.contains) || lower.startsWith('-') || lower.startsWith('•');
      if (!looksLikeIngredient) continue;

      var cleaned = lower.replaceAll('-', '').replaceAll('•', '').trim();
      cleaned = cleaned.replaceAll('1/2', '').replaceAll('1/4', '').replaceAll('3/4', '');
      for (var i = 0; i <= 9; i++) {
        cleaned = cleaned.replaceAll(i.toString(), '');
      }
      for (final unit in ['cups', 'cup', 'tbsp', 'tsp', 'grams', 'gram', 'kg', 'ml', 'oz', 'lbs', 'lb']) {
        cleaned = cleaned.replaceAll(unit, '');
      }
      cleaned = cleaned.trim();

      if (cleaned.isNotEmpty && cleaned.length <= 40) {
        candidates.add(cleaned);
      }
    }

    return candidates.take(20).toList();
  }

  List<String> _inferTags(String rawText) {
    final lower = rawText.toLowerCase();
    final tags = <String>{};

    if (lower.contains('spicy') || lower.contains('chili') || lower.contains('chilli')) tags.add('spicy');
    if (lower.contains('quick') || lower.contains('15 min') || lower.contains('20 min')) tags.add('quick');
    if (lower.contains('budget') || lower.contains('cheap')) tags.add('budget');
    if (lower.contains('rice')) tags.add('rice');
    if (lower.contains('protein') || lower.contains('chicken') || lower.contains('egg')) tags.add('protein');

    return tags.toList();
  }
}
