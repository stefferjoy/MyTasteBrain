import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/taste_memory.dart';
import '../../features/pantry/models/pantry_item.dart';

class AddPantryItemScreen extends StatefulWidget {
  const AddPantryItemScreen({super.key, this.forceLeftover = false});

  final bool forceLeftover;

  @override
  State<AddPantryItemScreen> createState() => _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends State<AddPantryItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _expiryDate;
  late bool _isLeftover;

  @override
  void initState() {
    super.initState();
    _isLeftover = widget.forceLeftover;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _expiryDate ?? now.add(const Duration(days: 3)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim().toLowerCase();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an item name.')),
      );
      return;
    }

    final item = PantryItem(
      name: name,
      category: _categoryController.text.trim().isEmpty ? 'other' : _categoryController.text.trim(),
      quantity: _quantityController.text.trim().isEmpty ? null : _quantityController.text.trim(),
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      expiryDate: _expiryDate,
      storageLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      isLeftover: _isLeftover,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await Provider.of<TasteMemoryModel>(context, listen: false).addPantryItem(item);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expiryLabel = _expiryDate == null
        ? 'No expiry date'
        : 'Expires ${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(widget.forceLeftover ? 'Add Leftover' : 'Add Pantry Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  hintText: 'rice, spinach, yogurt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: '2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'cups, pcs, g',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'protein, grain, vegetable',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage location',
                  hintText: 'fridge, freezer, pantry',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isLeftover,
                title: const Text('This is a leftover'),
                onChanged: widget.forceLeftover ? null : (value) => setState(() => _isLeftover = value),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickExpiryDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(expiryLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'half onion, cooked rice from yesterday',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: const Text('Save item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
