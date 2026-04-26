import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(recipe.sourceType)),
                if (recipe.cookedCount > 0) Chip(label: Text('Cooked ${recipe.cookedCount}')),
                if (recipe.skippedCount > 0) Chip(label: Text('Skipped ${recipe.skippedCount}')),
                ...recipe.tags.map((tag) => Chip(label: Text(tag))),
              ],
            ),
            if (recipe.creatorName != null || recipe.sourceUrl != null) ...[
              const SizedBox(height: 16),
              const Text('Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (recipe.creatorName != null) Text(recipe.creatorName!),
              if (recipe.sourceUrl != null) Text(recipe.sourceUrl!),
            ],
            const SizedBox(height: 16),
            const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...recipe.ingredients.map((ingredient) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(ingredient),
                )),
            if (recipe.steps.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(recipe.steps),
            ],
            if (recipe.rawText != null && recipe.rawText!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Raw saved text'),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(recipe.rawText!),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await tasteMemory.markRecipeCooked(recipe);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as cooked.')),
                );
              },
              icon: const Icon(Icons.restaurant_outlined),
              label: const Text('Mark cooked'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await tasteMemory.markRecipeSkipped(recipe, reason: 'Skipped from recipe detail');
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as skipped.')),
                );
              },
              icon: const Icon(Icons.not_interested_outlined),
              label: const Text('Mark skipped'),
            ),
          ],
        ),
      ),
    );
  }
}
