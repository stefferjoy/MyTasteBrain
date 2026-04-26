import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import 'add_recipe_screen.dart';
import 'import_recipe_screen.dart';
import 'pantry/pantry_screen.dart';
import 'saved_recipes_screen.dart';
import 'taste_brain/taste_brain_screen.dart';

/// The landing page of the app.
///
/// Users can enter ingredients they have at home and see recipe suggestions
/// ranked by local pantry match, leftovers, expiring items, and taste profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ingredientController = TextEditingController();

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _addIngredients(TasteMemoryModel tasteMemory) async {
    final text = _ingredientController.text;
    final parts = text.split(',');

    for (final part in parts) {
      await tasteMemory.addIngredient(part);
    }

    _ingredientController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context);
    final matches = tasteMemory.recipeMatches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Taste Brain'),
        actions: [
          IconButton(
            tooltip: 'Import recipe',
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImportRecipeScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Taste Brain',
            icon: const Icon(Icons.psychology_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TasteBrainScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Saved recipes',
            icon: const Icon(Icons.book_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Pantry',
            icon: const Icon(Icons.kitchen_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PantryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: tasteMemory.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: tasteMemory.load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Your private food memory',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add what you have at home. The app suggests saved recipes using local data only.',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.download_outlined),
                          label: const Text('Import recipe text'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ImportRecipeScreen()),
                            );
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.kitchen_outlined),
                          label: const Text('Pantry'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PantryScreen()),
                            );
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.psychology_outlined),
                          label: const Text('Taste Brain'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TasteBrainScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    if (tasteMemory.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Local database error: ${tasteMemory.errorMessage}'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientController,
                            decoration: const InputDecoration(
                              labelText: 'Ingredients at home',
                              hintText: 'rice, eggs, spinach, yogurt',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addIngredients(tasteMemory),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _addIngredients(tasteMemory),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tasteMemory.ingredientsAtHome.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          onDeleted: () => tasteMemory.removeIngredient(ingredient),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _QuickStats(tasteMemory: tasteMemory),
                    const SizedBox(height: 20),
                    const Text(
                      'Based on your food memory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (matches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'No recipe matches yet. Add a recipe and pantry items to start building your Taste Brain.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...matches.map((match) {
                        return Card(
                          child: ListTile(
                            title: Text(match.recipe.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(match.reason),
                                const SizedBox(height: 4),
                                if (match.missingIngredients.isEmpty)
                                  const Text('Ready to cook — no shopping needed.')
                                else
                                  Text('Missing: ${match.missingIngredients.join(', ')}'),
                              ],
                            ),
                            trailing: Text('${match.score}'),
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add recipe'),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.tasteMemory});

  final TasteMemoryModel tasteMemory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: 'Recipes', value: tasteMemory.savedRecipes.length.toString()),
        _StatChip(label: 'Pantry', value: tasteMemory.pantryItems.length.toString()),
        _StatChip(label: 'Leftovers', value: tasteMemory.leftovers.length.toString()),
        _StatChip(label: 'Use first', value: tasteMemory.expiringSoon.length.toString()),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
