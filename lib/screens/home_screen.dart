import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import 'add_recipe_screen.dart';
import 'saved_recipes_screen.dart';

/// The landing page of the app.
///
/// Users can enter ingredients they have at home and see recipe suggestions
/// ranked by how closely each saved recipe matches those ingredients.
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

  void _addIngredients(TasteMemoryModel tasteMemory) {
    final text = _ingredientController.text;
    final parts = text.split(',');

    for (final part in parts) {
      tasteMemory.addIngredient(part);
    }

    _ingredientController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context);
    final suggestions = tasteMemory.suggestRecipes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Taste Brain'),
        actions: [
          IconButton(
            tooltip: 'Saved recipes',
            icon: const Icon(Icons.book_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SavedRecipesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Add what you have at home. The app suggests saved recipes with the fewest missing ingredients.',
              ),
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
              const SizedBox(height: 20),
              const Text(
                'Based on your food memory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: suggestions.isEmpty
                    ? const Center(
                        child: Text('No recipes saved yet. Add a recipe to start building your Taste Brain.'),
                      )
                    : ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final recipe = suggestions[index];
                          final missing = recipe.missingIngredients(tasteMemory.ingredientsAtHome);

                          return Card(
                            child: ListTile(
                              title: Text(recipe.title),
                              subtitle: missing.isEmpty
                                  ? const Text('Ready to cook — no shopping needed.')
                                  : Text('Missing: ${missing.join(', ')}'),
                              trailing: missing.isEmpty
                                  ? const Icon(Icons.check_circle_outline)
                                  : Text('${missing.length} missing'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddRecipeScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add recipe'),
      ),
    );
  }
}
