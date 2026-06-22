import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/meal.dart';

/// Widget für eine einzelne Mahlzeit in der Mensaplan-Liste.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = meal.displayPrice;
    final priceText =
        price != null ? NumberFormat.currency(locale: 'de_DE', symbol: '€').format(price) : '–';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Semantics(
        label: '${meal.name}, ${meal.category}, $priceText',
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MealImage(imageUrl: meal.imageUrl, mealName: meal.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategorie-Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor(meal.category, theme),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        meal.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Gerichtname
                    Text(
                      meal.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Preis
                    Text(
                      priceText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    // Allergene (falls vorhanden)
                    if (meal.allergens.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: meal.allergens
                            .map((a) => Chip(
                                  label: Text(a),
                                  labelStyle: const TextStyle(fontSize: 10),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category, ThemeData theme) {
    final lower = category.toLowerCase();
    if (lower.contains('vegan')) return Colors.green.shade700;
    if (lower.contains('vegetar')) return Colors.lightGreen.shade600;
    if (lower.contains('fisch') || lower.contains('fish')) {
      return Colors.blue.shade600;
    }
    if (lower.contains('fleisch') || lower.contains('meat')) {
      return Colors.red.shade600;
    }
    if (lower.contains('suppe')) return Colors.orange.shade600;
    if (lower.contains('dessert') || lower.contains('nachspeise')) {
      return Colors.pink.shade400;
    }
    return theme.colorScheme.secondary;
  }
}

class _MealImage extends StatelessWidget {
  const _MealImage({required this.imageUrl, required this.mealName});

  final String? imageUrl;
  final String mealName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                semanticLabel: 'Bild von $mealName',
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.restaurant,
        color: Colors.grey,
        size: 32,
        semanticLabel: 'Kein Bild verfügbar',
      ),
    );
  }
}
