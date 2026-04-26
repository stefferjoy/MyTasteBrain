import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import '../features/recipes/services/recipe_text_parser.dart';

class ImportRecipeScreen extends StatefulWidget {
  const ImportRecipeScreen({super.key});

  @override
  State<ImportRecipeScreen> createState() => _ImportRecipeScreenState();
}

class _ImportRecipeScreenState extends State<ImportRecipeScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _sourceUrlController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  String _sourceType = 'pasted';
  bool _isSaving = false;

  final RecipeTextParser _parser = RecipeTextParser();

  @override
  void dispose() {
    _textController.dispose();
    _sourceUrlController.dispose();
    _creatorController.dispose();
    super.dispose();
  }

  Future<void> _importRecipe() async {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste recipe text or a social caption first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final recipe = _parser.parse(
      rawText: rawText,
      sourceType: _sourceType,
      sourceUrl: _sourceUrlController.text.trim().isEmpty ? null : _sourceUrlController.text.trim(),
      creatorName: _creatorController.text.trim().isEmpty ? null : _creatorController.text.trim(),
    );

    await Provider.of<TasteMemoryModel>(context, listen: false).addRecipe(recipe);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe imported into your local Taste Brain.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Recipe')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Paste a recipe caption or text',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'This MVP parser extracts a rough title, ingredients, tags, and steps locally. Local AI can clean this later.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sourceType,
              decoration: const InputDecoration(
                labelText: 'Source type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pasted', child: Text('Pasted text')),
                DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                DropdownMenuItem(value: 'tiktok', child: Text('TikTok')),
                DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                DropdownMenuItem(value: 'website', child: Text('Website')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sourceType = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sourceUrlController,
              decoration: const InputDecoration(
                labelText: 'Source URL optional',
                hintText: 'Paste the TikTok/Instagram/website link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _creatorController,
              decoration: const InputDecoration(
                labelText: 'Creator/source credit optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              minLines: 10,
              maxLines: 18,
              decoration: const InputDecoration(
                labelText: 'Recipe text or caption',
                hintText: 'Paste ingredients, steps, or social caption here',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSaving ? null : _importRecipe,
              icon: const Icon(Icons.save_alt_outlined),
              label: Text(_isSaving ? 'Importing...' : 'Import locally'),
            ),
          ],
        ),
      ),
    );
  }
}
