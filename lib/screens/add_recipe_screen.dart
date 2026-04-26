import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/taste_memory.dart';
import '../models/recipe.dart';

/// Screen for saving a new recipe into the user's local taste memory.
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _sourceUrlController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  final TextEditingController _rawTextController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  String _sourceType = 'manual';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _tagsController.dispose();
    _sourceUrlController.dispose();
    _creatorController.dispose();
    _rawTextController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    final title = _titleController.text.trim();
    final ingredients = _ingredientsController.text
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    final tags = _tagsController.text
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    if (title.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and at least one ingredient.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final recipe = Recipe(
      title: title,
      ingredients: ingredients,
      tags: tags,
      sourceType: _sourceType,
      sourceUrl: _sourceUrlController.text.trim().isEmpty ? null : _sourceUrlController.text.trim(),
      creatorName: _creatorController.text.trim().isEmpty ? null : _creatorController.text.trim(),
      rawText: _rawTextController.text.trim().isEmpty ? null : _rawTextController.text.trim(),
      steps: _stepsController.text.trim(),
    );

    await Provider.of<TasteMemoryModel>(context, listen: false).addRecipe(recipe);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe title',
                  hintText: 'Spicy egg fried rice',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _sourceType,
                decoration: const InputDecoration(
                  labelText: 'Source type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
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
                  hintText: 'Paste TikTok, Instagram, or recipe link',
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
                controller: _ingredientsController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  hintText: 'rice, eggs, spinach, soy sauce',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stepsController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Steps optional',
                  hintText: '1. Cook rice\n2. Fry eggs\n3. Mix with spinach',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rawTextController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Raw pasted text/caption optional',
                  hintText: 'Paste Instagram/TikTok caption or recipe text here',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags optional',
                  hintText: 'quick, spicy, budget',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving ? null : _saveRecipe,
                child: Text(_isSaving ? 'Saving...' : 'Save recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
