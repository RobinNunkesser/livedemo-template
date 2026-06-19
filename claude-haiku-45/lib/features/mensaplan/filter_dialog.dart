import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Filter dialog for Mensaplan
class FilterDialog extends ConsumerStatefulWidget {
  const FilterDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  static const List<String> categories = [
    'Fleisch',
    'Fisch',
    'Vegetarisch',
    'Vegan',
    'Eintopf',
    'Beilagen',
  ];

  static const List<String> allergens = [
    'Gluten',
    'Krebstiere',
    'Eier',
    'Fisch',
    'Erdnüsse',
    'Soja',
    'Milch',
    'Schalenfrüchte',
    'Sesam',
  ];

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return AlertDialog(
      title: const Text('Filter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategorien:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return FilterChip(
                  label: Text(cat),
                  selected: filterState.selectedCategories.contains(cat),
                  onSelected: (_) => filterNotifier.toggleCategory(cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Allergene ausblenden:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: allergens.map((allergen) {
                return FilterChip(
                  label: Text(allergen),
                  selected: filterState.selectedAllergens.contains(allergen),
                  onSelected: (_) => filterNotifier.toggleAllergen(allergen),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => filterNotifier.resetFilters(),
          child: const Text('Zurücksetzen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fertig'),
        ),
      ],
    );
  }
}
