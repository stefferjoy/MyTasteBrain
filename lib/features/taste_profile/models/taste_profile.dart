import '../../../core/utils/csv_utils.dart';

class TasteProfile {
  final List<String> preferredCuisines;
  final List<String> preferredTags;
  final List<String> dislikedIngredients;
  final int spiceLevel;
  final int maxCookingMinutes;
  final String budgetLevel;
  final String dietNotes;
  final DateTime updatedAt;

  const TasteProfile({
    required this.preferredCuisines,
    required this.preferredTags,
    required this.dislikedIngredients,
    required this.spiceLevel,
    required this.maxCookingMinutes,
    required this.budgetLevel,
    required this.dietNotes,
    required this.updatedAt,
  });

  factory TasteProfile.empty() {
    return TasteProfile(
      preferredCuisines: const [],
      preferredTags: const ['quick', 'budget', 'home-cooked'],
      dislikedIngredients: const [],
      spiceLevel: 3,
      maxCookingMinutes: 30,
      budgetLevel: 'medium',
      dietNotes: '',
      updatedAt: DateTime.now(),
    );
  }

  factory TasteProfile.fromMap(Map<String, Object?> map) {
    return TasteProfile(
      preferredCuisines: splitCsv(map['preferred_cuisines'] as String?),
      preferredTags: splitCsv(map['preferred_tags'] as String?),
      dislikedIngredients: splitCsv(map['disliked_ingredients'] as String?),
      spiceLevel: map['spice_level'] as int? ?? 3,
      maxCookingMinutes: map['max_cooking_minutes'] as int? ?? 30,
      budgetLevel: map['budget_level'] as String? ?? 'medium',
      dietNotes: map['diet_notes'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'preferred_cuisines': joinCsv(preferredCuisines),
      'preferred_tags': joinCsv(preferredTags),
      'disliked_ingredients': joinCsv(dislikedIngredients),
      'spice_level': spiceLevel,
      'max_cooking_minutes': maxCookingMinutes,
      'budget_level': budgetLevel,
      'diet_notes': dietNotes,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TasteProfile copyWith({
    List<String>? preferredCuisines,
    List<String>? preferredTags,
    List<String>? dislikedIngredients,
    int? spiceLevel,
    int? maxCookingMinutes,
    String? budgetLevel,
    String? dietNotes,
    DateTime? updatedAt,
  }) {
    return TasteProfile(
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      preferredTags: preferredTags ?? this.preferredTags,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      maxCookingMinutes: maxCookingMinutes ?? this.maxCookingMinutes,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      dietNotes: dietNotes ?? this.dietNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
