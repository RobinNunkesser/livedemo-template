import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class FilterDialog extends ConsumerWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mensaProvider);

    return AlertDialog(
      title: const Text('Filter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategorien',
              style: const TextStyle(fontWeight: FontWeight.bold),
              semanticsLabel: 'Kategorien filtern',
            ),
            const SizedBox(height: 8),
            ...MealCategory.values.map((category) {
              return Semantics(
                label: category.label,
                child: CheckboxListTile(
                  title: Text(category.label),
                  value: state.selectedCategories.contains(category),
                  onChanged: (bool? value) {
                    ref.read(mensaProvider.notifier).toggleCategory(category);
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
            const Divider(),
            Text(
              'Allergene',
              style: const TextStyle(fontWeight: FontWeight.bold),
              semanticsLabel: 'Allergene filtern',
            ),
            const SizedBox(height: 8),
            ...Allergen.values.map((allergen) {
              return Semantics(
                label: allergen.label,
                child: CheckboxListTile(
                  title: Text(allergen.label),
                  value: state.selectedAllergens.contains(allergen),
                  onChanged: (bool? value) {
                    ref.read(mensaProvider.notifier).toggleAllergen(allergen);
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(mensaProvider.notifier).resetFilters();
          },
          child: const Text('Zurücksetzen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}
