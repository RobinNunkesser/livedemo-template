import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers.dart';
import 'meal_card.dart';
import 'filter_dialog.dart';

class MensaplanScreen extends ConsumerWidget {
  const MensaplanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mensaProvider);

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
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, MensaState state) {
    if (state.isLoading) {
      return const LoadingState(message: 'Lade Mensaplan...');
    }

    if (state.error != null) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.read(mensaProvider.notifier).loadTodayMeals(),
      );
    }

    if (state.mensaDay == null) {
      return const EmptyState(
        message: 'Keine Daten verfügbar',
        icon: Icons.inbox,
      );
    }

    if (state.mensaDay!.closed) {
      return const EmptyState(
        message: 'Die Mensa hat heute geschlossen.',
        icon: Icons.restaurant_menu,
      );
    }

    final filteredMeals = state.filteredMeals;

    if (filteredMeals.isEmpty) {
      return const EmptyState(
        message: 'Keine Gerichte gefunden. Versuchen Sie andere Filter.',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(mensaProvider.notifier).loadTodayMeals(),
      child: ListView.builder(
        itemCount: filteredMeals.length,
        itemBuilder: (context, index) {
          return MealCard(meal: filteredMeals[index]);
        },
      ),
    );
  }
}
