import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

const _allergenCodes = {
  'A': 'Glutenhaltiges Getreide',
  'B': 'Krebstiere',
  'C': 'Eier',
  'D': 'Fisch',
  'E': 'Erdnüsse',
  'F': 'Soja',
  'G': 'Milch/Laktose',
  'H': 'Schalenfrüchte (Nüsse)',
  'L': 'Sellerie',
  'M': 'Senf',
  'N': 'Sesam',
  'O': 'Schwefeldioxid/Sulfit',
  'P': 'Lupinen',
  'R': 'Weichtiere',
};

const _categoryLabels = ['Fleisch', 'Fisch', 'Vegetarisch', 'Vegan'];

class FilterDialog extends ConsumerStatefulWidget {
  const FilterDialog({super.key});

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  late Set<String> _selectedAllergens;
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    final state = ref.read(mensaplanProvider);
    _selectedAllergens = Set.from(state.selectedAllergens);
    _selectedCategories = Set.from(state.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Filter', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Kategorien', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ..._categoryLabels.map((cat) {
                return CheckboxListTile(
                  title: Text(cat),
                  value: _selectedCategories.contains(cat),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }),
              const Divider(height: 32),
              Text('Allergene ausblenden', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                'Gerichte mit ausgewählten Allergenen werden ausgeblendet.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ..._allergenCodes.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: _selectedAllergens.contains(entry.key),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedAllergens.add(entry.key);
                      } else {
                        _selectedAllergens.remove(entry.key);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAllergens = {};
                        _selectedCategories = {};
                      });
                    },
                    child: const Text('Zurücksetzen'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(mensaplanProvider.notifier)
                          .setAllergens(_selectedAllergens);
                      ref
                          .read(mensaplanProvider.notifier)
                          .setCategories(_selectedCategories);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Anwenden'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
