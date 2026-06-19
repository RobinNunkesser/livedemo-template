import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/meal.dart';
import 'providers.dart';

/// Filter-Dialog für Allergene, Zusatzstoffe und Kategorien.
/// Laut Feature-Mensaplan: AF 1A (Allergen), AF 1B (Kategorie), AF 1C (kombiniert).
class FilterDialog extends ConsumerWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterNotifierProvider);
    final filterNotifier = ref.read(filterNotifierProvider.notifier);
    final availableCategories = ref.watch(availableCategoriesProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (filters.hasActiveFilters)
                    TextButton(
                      onPressed: filterNotifier.clearAll,
                      child: const Text('Zurücksetzen'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Schließen',
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Allergene
                      const Text(
                        '14 EU-Hauptallergene ausblenden',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gerichte, die diese Allergene enthalten, werden ausgeblendet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ...Meal.allAllergenLabels.map(
                        (allergen) => CheckboxListTile(
                          value: filters.selectedAllergens.contains(allergen),
                          onChanged: (_) =>
                              filterNotifier.toggleAllergen(allergen),
                          title: Text(allergen),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Zusatzstoffe
                      const Text(
                        'Zusatzstoffe ausblenden',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...Meal.allAdditiveLabels.map(
                        (additive) => CheckboxListTile(
                          value: filters.selectedAllergens.contains(additive),
                          onChanged: (_) =>
                              filterNotifier.toggleAllergen(additive),
                          title: Text(additive),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      // Kategorien (nur wenn Mahlzeiten geladen)
                      if (availableCategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Kategorien anzeigen',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Leer lassen um alle Kategorien anzuzeigen.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...availableCategories.map(
                          (category) => CheckboxListTile(
                            value: filters.selectedCategories.isEmpty ||
                                filters.selectedCategories.contains(category),
                            onChanged: (_) =>
                                filterNotifier.toggleCategory(category),
                            title: Text(category),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fertig'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
