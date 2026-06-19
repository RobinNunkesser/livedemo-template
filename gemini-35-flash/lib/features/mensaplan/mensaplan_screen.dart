import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers.dart';
import '../../domain/meal.dart';
import 'meal_card.dart';
import 'filter_dialog.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/empty_state.dart';

class MensaplanScreen extends ConsumerWidget {
  const MensaplanScreen({super.key});

  void _openFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: FilterDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mensaStateProvider);
    final filter = ref.watch(mensaFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final todayStr = DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now());

    // Build filter summary text
    final List<String> activeFilters = [];
    if (filter.categories.isNotEmpty) {
      activeFilters.add('${filter.categories.length} Kat.');
    }
    if (filter.avoidAllergens.isNotEmpty) {
      activeFilters.add('${filter.avoidAllergens.length} Allergene gemieden');
    }
    if (filter.avoidAdditives.isNotEmpty) {
      activeFilters.add('${filter.avoidAdditives.length} Zusatzstoffe gemieden');
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mensaplan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              todayStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter öffnen',
            onPressed: () => _openFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Summary Bar
          Container(
            color: colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: activeFilters.isEmpty
                        ? 'Keine Filter aktiv'
                        : 'Aktive Filter: ${activeFilters.join(", ")}',
                    child: Text(
                      activeFilters.isEmpty
                          ? 'Keine Filter aktiv'
                          : 'Aktiv: ${activeFilters.join(" | ")}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: activeFilters.isEmpty
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (activeFilters.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(mensaFilterProvider.notifier).resetFilters();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Zurücksetzen'),
                  ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _buildBody(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, MensaState state) {
    switch (state.status) {
      case MensaScreenStatus.loading:
        return const LoadingState(message: 'Lade heutige Speisen...');

      case MensaScreenStatus.error:
        return ErrorState(
          title: 'Fehler beim Laden',
          message: state.errorMessage ?? 'Die Mensadaten konnten nicht abgerufen werden.',
          onRetry: () {
            ref.read(mensaStateProvider.notifier).loadMeals();
          },
        );

      case MensaScreenStatus.closed:
        return const EmptyState(
          title: 'Mensa heute geschlossen',
          message: 'Die Mensa hat heute leider kein Angebot (z. B. am Wochenende oder Feiertag).',
          icon: Icons.store_mall_directory_outlined,
        );

      case MensaScreenStatus.empty:
        return EmptyState(
          title: 'Keine Gerichte',
          message: state.allMeals.isEmpty
              ? 'Für heute sind keine Gerichte eingetragen.'
              : 'Durch die aktiven Filter wurden alle heutigen Gerichte ausgeblendet.',
          icon: Icons.no_food_outlined,
        );

      case MensaScreenStatus.loaded:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.filteredMeals.length,
          itemBuilder: (context, index) {
            final meal = state.filteredMeals[index];
            return MealCard(
              meal: meal,
              onTap: () => _showMealDetail(context, meal),
            );
          },
        );
    }
  }

  void _showMealDetail(BuildContext context, Meal meal) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull indicator
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

              // Title & Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kategorie: ${meal.category} (${meal.dietaryType})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image section if available
              if (meal.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    meal.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Prices Card
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriceColumn(
                        context,
                        'Studierende',
                        '${meal.studentPrice.toStringAsFixed(2)} €',
                        colorScheme.onPrimaryContainer,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                      ),
                      _buildPriceColumn(
                        context,
                        'Bedienstete',
                        '${meal.employeePrice.toStringAsFixed(2)} €',
                        colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Allergens
              if (meal.allergens.isNotEmpty) ...[
                Text(
                  'Allergene',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.allergens.join(', '),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.orange.shade900),
                ),
                const SizedBox(height: 16),
              ],

              // Additives
              if (meal.additives.isNotEmpty) ...[
                Text(
                  'Zusatzstoffe',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.additives.join(', '),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Schließen'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceColumn(BuildContext context, String label, String price, Color textColor) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
