/// Filter-Dialog für Kategorie- und Allergen-Filter (A4, A6, A16).
///
/// Bietet Anwenden und Zurücksetzen (A13). Der Zustand wird beim Anwenden
/// an den FilterNotifier übergeben, der persistiert (A14).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/allergens.dart';
import '../../domain/meal.dart';
import 'providers.dart';

class FilterDialog extends ConsumerStatefulWidget {
  const FilterDialog({super.key});

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  late Set<String> _allergens;
  late Set<String> _categories;

  @override
  void initState() {
    super.initState();
    final current = ref.read(filterProvider);
    _allergens = {...current.hiddenAllergens};
    _categories = {...current.selectedCategories};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kategorien (inklusiv)
              Text('Kategorien', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 0,
                children: FoodCategory.values.map((c) {
                  return FilterChip(
                    label: Text(c.label),
                    selected: _categories.contains(c.name),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _categories.add(c.name);
                        } else {
                          _categories.remove(c.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Allergene / Zusatzstoffe ausblenden',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 0,
                children: AllergenCatalog.all.map((a) {
                  return FilterChip(
                    label: Text(a.name),
                    selected: _allergens.contains(a.code),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _allergens.add(a.code);
                        } else {
                          _allergens.remove(a.code);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _allergens.clear();
            _categories.clear();
          }),
          child: const Text('Zurücksetzen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () async {
            final notifier = ref.read(filterProvider.notifier);
            await notifier.setAllergens(_allergens);
            await notifier.setCategories(_categories);
            final navigator = Navigator.of(context);
            if (mounted) navigator.pop();
          },
          child: const Text('Anwenden'),
        ),
      ],
    );
  }
}
