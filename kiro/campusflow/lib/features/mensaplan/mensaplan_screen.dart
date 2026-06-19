import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import 'filter_dialog.dart';
import 'meal_card.dart';
import 'providers.dart';

/// Mensaplan-Hauptscreen – SP1-05 bis SP1-08.
///
/// Accessibility-Umsetzung (SP1-10 / WCAG 2.1 AA):
/// - Semantik-Labels auf allen interaktiven Elementen
/// - Sichtbare Fokus-Indikatoren über Material 3
/// - Ausreichende Kontraste durch ThemeData
class MensaplanScreen extends ConsumerWidget {
  const MensaplanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mensaState = ref.watch(mensaNotifierProvider);
    final filters = ref.watch(filterNotifierProvider);
    final formattedDate =
        DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text('Mensaplan – $formattedDate'),
        ),
        actions: [
          // Filter-Badge zeigt aktive Filter an
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: () => _openFilter(context),
              ),
              if (filters.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Neu laden',
            onPressed: () =>
                ref.read(mensaNotifierProvider.notifier).load(),
          ),
        ],
      ),
      body: _buildBody(context, ref, mensaState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, MensaState state) {
    return switch (state) {
      MensaLoading() => const LoadingState(message: 'Mensaplan wird geladen…'),
      MensaClosed() => EmptyState(
          icon: Icons.store_outlined,
          message: '⚠️ Mensa heute geschlossen\n\n'
              'Die Mensa hat heute keine Öffnungszeiten.',
        ),
      MensaEmpty() => EmptyState(
          icon: Icons.no_meals_outlined,
          message: 'Kein Speisenangebot für heute verfügbar.',
          onAction: () =>
              ref.read(mensaNotifierProvider.notifier).load(),
          actionLabel: 'Neu laden',
        ),
      MensaError(message: final msg) => ErrorState(
          message: msg,
          onRetry: () => ref.read(mensaNotifierProvider.notifier).load(),
        ),
      MensaLoaded() => _buildMealList(context, ref),
    };
  }

  Widget _buildMealList(BuildContext context, WidgetRef ref) {
    final filteredMeals = ref.watch(filteredMealsProvider);
    final filters = ref.watch(filterNotifierProvider);

    if (filteredMeals.isEmpty) {
      return EmptyState(
        icon: Icons.filter_alt_off_outlined,
        message: filters.hasActiveFilters
            ? 'Keine Gerichte entsprechen den aktuellen Filtern.\n'
                'Filter zurücksetzen um alle Gerichte anzuzeigen.'
            : 'Keine Gerichte für heute verfügbar.',
        onAction: filters.hasActiveFilters
            ? () => ref.read(filterNotifierProvider.notifier).clearAll()
            : null,
        actionLabel: 'Filter zurücksetzen',
      );
    }

    return Column(
      children: [
        // Aktive Filter-Anzeige
        if (filters.hasActiveFilters)
          Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filter aktiv',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(filterNotifierProvider.notifier).clearAll(),
                    child: const Text('Zurücksetzen'),
                  ),
                ],
              ),
            ),
          ),
        // Mahlzeiten-Liste
        Expanded(
          child: Semantics(
            label: '${filteredMeals.length} Gerichte',
            child: ListView.builder(
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) =>
                  MealCard(meal: filteredMeals[index]),
            ),
          ),
        ),
      ],
    );
  }

  void _openFilter(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const FilterDialog(),
    );
  }
}
