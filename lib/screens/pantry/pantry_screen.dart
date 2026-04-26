import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/taste_memory.dart';
import '../../features/pantry/models/pantry_item.dart';
import 'add_pantry_item_screen.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context);
    final pantryItems = tasteMemory.pantryItems;
    final leftovers = tasteMemory.leftovers;
    final expiringSoon = tasteMemory.expiringSoon;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry + Leftovers'),
        actions: [
          IconButton(
            tooltip: 'Add leftover',
            icon: const Icon(Icons.history_toggle_off),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddPantryItemScreen(forceLeftover: true),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: pantryItems.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Add pantry items or leftovers to help My Taste Brain suggest what you can cook now.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (expiringSoon.isNotEmpty) ...[
                    const _SectionHeader(title: 'Use first'),
                    ...expiringSoon.map((item) => _PantryItemCard(item: item)),
                    const SizedBox(height: 16),
                  ],
                  if (leftovers.isNotEmpty) ...[
                    const _SectionHeader(title: 'Leftovers'),
                    ...leftovers.map((item) => _PantryItemCard(item: item)),
                    const SizedBox(height: 16),
                  ],
                  const _SectionHeader(title: 'All pantry items'),
                  ...pantryItems.map((item) => _PantryItemCard(item: item)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPantryItemScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PantryItemCard extends StatelessWidget {
  const _PantryItemCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final tasteMemory = Provider.of<TasteMemoryModel>(context, listen: false);
    final expiry = item.expiryDate;
    final details = <String>[
      if (item.quantity != null && item.quantity!.isNotEmpty) item.quantity!,
      if (item.unit != null && item.unit!.isNotEmpty) item.unit!,
      if (item.storageLocation != null && item.storageLocation!.isNotEmpty) item.storageLocation!,
      if (expiry != null) 'expires ${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}',
    ];

    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(details.isEmpty ? item.category : details.join(' • ')),
        leading: Icon(item.isLeftover ? Icons.history_toggle_off : Icons.kitchen_outlined),
        trailing: IconButton(
          tooltip: 'Mark used',
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => tasteMemory.markPantryItemUsed(item),
        ),
      ),
    );
  }
}
