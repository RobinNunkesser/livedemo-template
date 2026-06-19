/// Widget für eine einzelne Mensa-Speise (A2, A3, A5).
library;

import 'package:flutter/material.dart';

import '../../domain/meal.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = _categoryColor(meal.foodCategory, theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bild oder Platzhalter (A3)
          SizedBox(
            width: 88,
            height: 88,
            child: meal.imageUrl != null
                ? Image.network(
                    meal.imageUrl!,
                    fit: BoxFit.cover,
                    semanticLabel: 'Bild von ${meal.name}',
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Kategorie-Badge (A16)
                      Chip(
                        label: Text(meal.foodCategory.label),
                        backgroundColor: catColor.withValues(alpha: 0.15),
                        labelStyle: TextStyle(color: catColor),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      if (meal.priceDisplay.isNotEmpty)
                        Text(
                          meal.priceDisplay,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (meal.allergens.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        // Lesbare Allergen-Namen (A5: keine Codes)
                        meal.allergens.map((a) => a.name).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => ColoredBox(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.restaurant, color: Colors.grey),
        ),
      );

  Color _categoryColor(FoodCategory cat, ThemeData theme) {
    switch (cat) {
      case FoodCategory.vegan:
        return Colors.green;
      case FoodCategory.vegetarisch:
        return Colors.lightGreen;
      case FoodCategory.fleisch:
        return Colors.red.shade700;
      case FoodCategory.fisch:
        return Colors.blue;
      case FoodCategory.sonstiges:
        return theme.colorScheme.outline;
    }
  }
}
