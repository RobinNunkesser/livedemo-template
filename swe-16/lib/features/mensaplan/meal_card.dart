import 'package:flutter/material.dart';
import '../../domain/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({required this.meal, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        label:
            '${meal.name}, ${meal.category}, ${meal.price.toStringAsFixed(2)} Euro',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image or placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: meal.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal.image!,
                          fit: BoxFit.cover,
                          semanticLabel: 'Bild von ${meal.name}',
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant,
                              size: 40,
                              semanticLabel: 'Kein Bild verfügbar',
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 40,
                        semanticLabel: 'Kein Bild verfügbar',
                      ),
              ),
              const SizedBox(width: 16),
              // Meal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      semanticsLabel: meal.name,
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: meal.category,
                      child: Chip(
                        label: Text(meal.category),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '€${meal.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      semanticsLabel: '${meal.price.toStringAsFixed(2)} Euro',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
