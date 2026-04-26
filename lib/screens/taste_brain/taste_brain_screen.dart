import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/taste_memory.dart';
import '../../features/taste_profile/models/taste_profile.dart';

class TasteBrainScreen extends StatefulWidget {
  const TasteBrainScreen({super.key});

  @override
  State<TasteBrainScreen> createState() => _TasteBrainScreenState();
}

class _TasteBrainScreenState extends State<TasteBrainScreen> {
  final TextEditingController _cuisinesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _dislikesController = TextEditingController();
  final TextEditingController _dietNotesController = TextEditingController();
  final TextEditingController _maxCookingController = TextEditingController();
  String _budgetLevel = 'medium';
  double _spiceLevel = 3;
  bool _initialized = false;

  @override
  void dispose() {
    _cuisinesController.dispose();
    _tagsController.dispose();
    _dislikesController.dispose();
    _dietNotesController.dispose();
    _maxCookingController.dispose();
    super.dispose();
  }

  void _initialize(TasteProfile profile) {
    if (_initialized) return;
    _cuisinesController.text = profile.preferredCuisines.join(', ');
    _tagsController.text = profile.preferredTags.join(', ');
    _dislikesController.text = profile.dislikedIngredients.join(', ');
    _dietNotesController.text = profile.dietNotes;
    _maxCookingController.text = profile.maxCookingMinutes.toString();
    _budgetLevel = profile.budgetLevel;
    _spiceLevel = profile.spiceLevel.toDouble();
    _initialized = true;
  }

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _save(TasteMemoryModel tasteMemory) async {
    final maxMinutes = int.tryParse(_maxCookingController.text.trim()) ?? 30;
    final profile = TasteProfile(
      preferredCuisines: _splitList(_cuisinesController.text),
      preferredTags: _splitList(_tagsController.text),
      dislikedIngredients: _splitList(_dislikesController.text),
      spiceLevel: _spiceLevel.round().clamp(1, 5),
      maxCookingMinutes: maxMinutes.clamp(5, 240),
      budgetLevel: _budgetLevel,
      dietNotes: _dietNotesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await tasteMemory.saveTasteProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taste profile saved locally.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context);
    _initialize(tasteMemory.tasteProfile);

    return Scaffold(
      appBar: AppBar(title: const Text('Taste Brain')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Private taste profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'These preferences stay in the local database and help rank recipe matches.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _cuisinesController,
              decoration: const InputDecoration(
                labelText: 'Preferred cuisines',
                hintText: 'indian, italian, mexican',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Preferred recipe tags',
                hintText: 'quick, spicy, budget, rice bowl',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dislikesController,
              decoration: const InputDecoration(
                labelText: 'Disliked ingredients',
                hintText: 'mushrooms, olives',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxCookingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max cooking minutes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _budgetLevel,
              decoration: const InputDecoration(
                labelText: 'Budget level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _budgetLevel = value);
              },
            ),
            const SizedBox(height: 16),
            Text('Spice level: ${_spiceLevel.round()}'),
            Slider(
              value: _spiceLevel,
              min: 1,
              max: 5,
              divisions: 4,
              label: _spiceLevel.round().toString(),
              onChanged: (value) => setState(() => _spiceLevel = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dietNotesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Diet notes',
                hintText: 'high protein, avoid heavy meals at night',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _save(tasteMemory),
              child: const Text('Save taste profile'),
            ),
          ],
        ),
      ),
    );
  }
}
