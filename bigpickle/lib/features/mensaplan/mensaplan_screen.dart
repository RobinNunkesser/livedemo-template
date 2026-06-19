import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers.dart';
import 'meal_card.dart';
import 'filter_dialog.dart';

class MensaplanScreen extends ConsumerStatefulWidget {
  const MensaplanScreen({super.key});

  @override
  ConsumerState<MensaplanScreen> createState() => _MensaplanScreenState();
}

class _MensaplanScreenState extends ConsumerState<MensaplanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mensaplanProvider.notifier).loadMensaplan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mensaplanProvider);
    final hasActiveFilters =
        state.selectedAllergens.isNotEmpty ||
        state.selectedCategories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensaplan'),
        actions: [
          if (state.state == MensaState.loaded)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const FilterDialog(),
                );
              },
              icon: Badge(
                isLabelVisible: hasActiveFilters,
                child: const Icon(Icons.filter_list),
              ),
              tooltip: 'Filter',
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MensaplanState state) {
    switch (state.state) {
      case MensaState.initial:
      case MensaState.loading:
        return const LoadingState(message: 'Mensaplan wird geladen …');

      case MensaState.error:
        return ErrorState(
          title: 'Mensaplan nicht verfügbar',
          message:
              state.errorMessage ??
              'Die Daten konnten gerade nicht geladen werden.',
          onRetry: () => ref.read(mensaplanProvider.notifier).loadMensaplan(),
        );

      case MensaState.closed:
        return const EmptyState(
          title: 'Mensa heute geschlossen',
          message: 'Die Mensa hat heute keine Öffnungszeiten.',
          icon: Icons.lock_clock,
        );

      case MensaState.noMeals:
        return const EmptyState(
          title: 'Kein Angebot',
          message: 'Für heute ist kein Speiseangebot verfügbar.',
          icon: Icons.restaurant_menu,
        );

      case MensaState.loaded:
        final meals = state.filteredMeals;
        if (meals.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: EmptyState(
                  title: 'Keine Gerichte',
                  message:
                      'Keine Gerichte entsprechen deinen Filtereinstellungen.',
                  icon: Icons.filter_alt_off,
                ),
              ),
              if (state.selectedAllergens.isNotEmpty ||
                  state.selectedCategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(mensaplanProvider.notifier).resetFilters(),
                    child: const Text('Filter zurücksetzen'),
                  ),
                ),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(mensaplanProvider.notifier).loadMensaplan(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: meals.length,
            itemBuilder: (_, i) => MealCard(meal: meals[i]),
          ),
        );
    }
  }
}
