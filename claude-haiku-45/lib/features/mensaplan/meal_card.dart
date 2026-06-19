import 'package:flutter/material.dart';

import '../../domain/meal.dart';

/// Card widget for displaying a single meal
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealCard({Key? key, required this.meal, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceText = _getDisplayPrice();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          meal.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(meal.category),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                if (meal.allergens.isNotEmpty)
                  Chip(
                    label: Text('${meal.allergens.length} Allergene'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Preis: $priceText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getDisplayPrice() {
    final students = meal.prices['students'];
    final employees = meal.prices['employees'];
    final pupils = meal.prices['pupils'];

    if (students != null && students > 0) {
      return '${students.toStringAsFixed(2)} € (Studierende)';
    } else if (employees != null && employees > 0) {
      return '${employees.toStringAsFixed(2)} € (Beschäftigte)';
    } else if (pupils != null && pupils > 0) {
      return '${pupils.toStringAsFixed(2)} € (Schüler)';
    }
    return 'Preis unbekannt';
  }
}
