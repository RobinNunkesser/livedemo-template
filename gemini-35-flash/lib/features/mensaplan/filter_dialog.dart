import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import '../../domain/meal.dart';

class FilterDialog extends ConsumerStatefulWidget {
  const FilterDialog({super.key});

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _MainAllergenList {
  static const List<String> allergens = [
    'Glutenhaltiges Getreide',
    'Krebstiere',
    'Eier',
    'Fisch',
    'Erdnüsse',
    'Soja',
    'Milch/Laktose',
    'Schalenfrüchte (Nüsse)',
    'Sellerie',
    'Senf',
    'Sesam',
    'Schwefeldioxid/Sulfit',
    'Lupinen',
    'Weichtiere',
  ];

  static const List<String> additives = [
    'Künstliche Farbstoffe',
    'Konservierungsstoffe',
    'Antioxidationsmittel',
    'Geschmacksverstärker',
  ];
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  late List<String> _selectedCategories;
  late List<String> _selectedAllergens;
  late List<String> _selectedAdditives;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(mensaFilterProvider);
    _selectedCategories = List.from(currentFilter.categories);
    _selectedAllergens = List.from(currentFilter.avoidAllergens);
    _selectedAdditives = List.from(currentFilter.avoidAdditives);
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedAllergens.clear();
      _selectedAdditives.clear();
    });
  }

  void _applyFilters() {
    final newFilter = MensaFilter(
      categories: _selectedCategories,
      avoidAllergens: _selectedAllergens,
      avoidAdditives: _selectedAdditives,
    );
    ref.read(mensaFilterProvider.notifier).saveFilters(newFilter);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Indicator
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Allergene',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content area (Scrollable)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  Text(
                    'Kategorien',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Vegan', 'Vegetarisch', 'Fleisch'].map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(cat);
                            } else {
                              _selectedCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Allergens to avoid Section
                  Text(
                    'Allergene ausschließen',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Gerichte mit ausgewählten Allergenen werden ausgeblendet.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _MainAllergenList.allergens.length,
                    itemBuilder: (context, index) {
                      final allergen = _MainAllergenList.allergens[index];
                      final isChecked = _selectedAllergens.contains(allergen);
                      return CheckboxListTile(
                        title: Text(allergen),
                        value: isChecked,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAllergens.add(allergen);
                            } else {
                              _selectedAllergens.remove(allergen);
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Additives to avoid Section
                  Text(
                    'Zusatzstoffe ausschließen',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Gerichte mit ausgewählten Zusatzstoffen werden ausgeblendet.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _MainAllergenList.additives.length,
                    itemBuilder: (context, index) {
                      final additive = _MainAllergenList.additives[index];
                      final isChecked = _selectedAdditives.contains(additive);
                      return CheckboxListTile(
                        title: Text(additive),
                        value: isChecked,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAdditives.add(additive);
                            } else {
                              _selectedAdditives.remove(additive);
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Zurücksetzen'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('Anwenden'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
