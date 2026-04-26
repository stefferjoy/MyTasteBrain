import '../core/utils/csv_utils.dart';

/// A saved recipe inside the user's private food memory.
class Recipe {
  final int? id;
  final String title;
  final List<String> ingredients;
  final List<String> tags;
  final String sourceType;
  final String? sourceUrl;
  final String? creatorName;
  final String? rawText;
  final String? summary;
  final String steps;
  final int cookedCount;
  final int skippedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.title,
    required this.ingredients,
    this.tags = const [],
    this.sourceType = 'manual',
    this.sourceUrl,
    this.creatorName,
    this.rawText,
    this.summary,
    this.steps = '',
    this.cookedCount = 0,
    this.skippedCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Recipe.fromMap(Map<String, Object?> map, List<String> ingredients) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String? ?? 'Untitled recipe',
      ingredients: ingredients,
      tags: splitCsv(map['tags'] as String?),
      sourceType: map['source_type'] as String? ?? 'manual',
      sourceUrl: map['source_url'] as String?,
      creatorName: map['creator_name'] as String?,
      rawText: map['raw_text'] as String?,
      summary: map['summary'] as String?,
      steps: map['steps'] as String? ?? '',
      cookedCount: map['cooked_count'] as int? ?? 0,
      skippedCount: map['skipped_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, Object?> toRecipeMap() {
    return {
      'title': title,
      'source_type': sourceType,
      'source_url': sourceUrl,
      'creator_name': creatorName,
      'raw_text': rawText,
      'summary': summary,
      'steps': steps,
      'tags': joinCsv(tags),
      'cooked_count': cookedCount,
      'skipped_count': skippedCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Computes which ingredients from this recipe are missing based on
  /// the ingredients the user currently has at home.
  List<String> missingIngredients(List<String> ingredientsAtHome) {
    final lowerHome = ingredientsAtHome.map((e) => e.trim().toLowerCase()).toSet();

    return ingredients
        .where((ingredient) => !lowerHome.contains(ingredient.trim().toLowerCase()))
        .toList();
  }

  Recipe copyWith({
    int? id,
    String? title,
    List<String>? ingredients,
    List<String>? tags,
    String? sourceType,
    String? sourceUrl,
    String? creatorName,
    String? rawText,
    String? summary,
    String? steps,
    int? cookedCount,
    int? skippedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      tags: tags ?? this.tags,
      sourceType: sourceType ?? this.sourceType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      creatorName: creatorName ?? this.creatorName,
      rawText: rawText ?? this.rawText,
      summary: summary ?? this.summary,
      steps: steps ?? this.steps,
      cookedCount: cookedCount ?? this.cookedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
