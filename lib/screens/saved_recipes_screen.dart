import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import 'recipe_detail_screen.dart';

/// Displays all saved recipes in the user's local taste memory.
class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedRecipes = Provider.of<TasteMemoryModel>(context).savedRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: SafeArea(
        child: savedRecipes.isEmpty
            ? const Center(
                child: Text('No recipes saved yet.'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: savedRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final recipe = savedRecipes[index];

                  return Card(
                    child: ListTile(
                      title: Text(recipe.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.ingredients.join(', ')),
                          if (recipe.tags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Tags: ${recipe.tags.join(', ')}'),
                          ],
                          const SizedBox(height: 4),
                          Text('Source: ${recipe.sourceType}'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
