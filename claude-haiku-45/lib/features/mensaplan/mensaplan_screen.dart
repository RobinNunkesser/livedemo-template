import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/empty_state.dart';
import '../../domain/meal.dart';
import 'providers.dart';
import 'meal_card.dart';
import 'filter_dialog.dart';

/// Main Mensaplan Screen
class MensaplanScreen extends ConsumerStatefulWidget {
  const MensaplanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MensaplanScreen> createState() => _MensaplanScreenState();
}

class _MensaplanScreenState extends ConsumerState<MensaplanScreen> {
  @override
  void initState() {
    super.initState();
    // Load meals on screen init
    Future.microtask(() {
      ref.read(mensaProvider.notifier).loadMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mensaState = ref.watch(mensaProvider);
    final filteredMeals = ref.watch(filteredMealsProvider);
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensaplan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const FilterDialog(),
              );
            },
          ),
        ],
      ),
      body: _buildBody(
        mensaState,
        filteredMeals,
        filterState.selectedCategories.isNotEmpty ||
            filterState.selectedAllergens.isNotEmpty,
      ),
    );
  }

  Widget _buildBody(MensaState state, List<Meal> meals, bool filtersApplied) {
    if (state.isLoading) {
      return const LoadingState(message: 'Mensaplan wird geladen...');
    }

    if (state.error != null) {
      return ErrorState(
        message: 'Fehler beim Laden des Mensaplans:\n${state.error}',
        onRetry: () {
          ref.read(mensaProvider.notifier).loadMeals();
        },
      );
    }

    if (state.isClosed) {
      return const EmptyState(
        message: 'Die Mensa ist heute geschlossen',
        subMessage: 'Genießen Sie Ihren freien Tag!',
        icon: Icons.no_meals,
      );
    }

    if (state.day == null || state.day!.meals.isEmpty) {
      return const EmptyState(
        message: 'Keine Speisen für heute',
        subMessage: 'Die Mensa hat heute kein Angebot',
        icon: Icons.no_meals_outlined,
      );
    }

    if (meals.isEmpty && filtersApplied) {
      return const EmptyState(
        message: 'Keine Speisen passen zu Ihren Filtern',
        subMessage: 'Versuchen Sie, die Filtereinstellungen anzupassen',
        icon: Icons.filter_list_off,
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speisen für heute',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...meals.map((meal) => MealCard(meal: meal)).toList(),
          ],
        ),
      ),
    );
  }
}
