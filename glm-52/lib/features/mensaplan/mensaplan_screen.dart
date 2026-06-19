/// Mensaplan-Hauptbildschirm (SP1-05 bis SP1-08).
///
/// Zeigt die Gerichte des heutigen Tages, filterbar nach Kategorie und
/// Allergenen. Behandelt Lade-, Fehler-, Leer- und Geschlossen-Zustände.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import 'filter_dialog.dart';
import 'meal_card.dart';
import 'providers.dart';

class MensaplanScreen extends ConsumerStatefulWidget {
  const MensaplanScreen({super.key});

  @override
  ConsumerState<MensaplanScreen> createState() => _MensaplanScreenState();
}

class _MensaplanScreenState extends ConsumerState<MensaplanScreen> {
  @override
  void initState() {
    super.initState();
    // Initialer Ladevorgang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mensaProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mensaProvider);
    final meals = ref.watch(filteredMealsProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensaplan – Heute'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Neu laden',
            onPressed: () => ref.read(mensaProvider.notifier).load(),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: !filter.isEmpty,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const FilterDialog(),
            ),
          ),
        ],
      ),
      body: _body(state, meals),
    );
  }

  Widget _body(MensaState state, List<dynamic> meals) {
    return switch (state) {
      MensaLoading() => const LoadingState(message: 'Speisen werden geladen …'),
      MensaError(:final message) => ErrorState(
          message: message,
          onRetry: () => ref.read(mensaProvider.notifier).load(),
        ),
      MensaClosed() => const EmptyState(
          icon: Icons.do_not_disturb_alt_outlined,
          title: 'Mensa heute geschlossen',
          subtitle: 'Die Mensa hat heute keine Öffnungszeiten.',
        ),
      MensaEmpty() => const EmptyState(
          icon: Icons.no_food_outlined,
          title: 'Kein Angebot heute',
          subtitle: 'Für heute sind keine Speisen hinterlegt.',
        ),
      MensaData() => meals.isEmpty
          ? const EmptyState(
              title: 'Keine passenden Speisen',
              subtitle: 'Die aktiven Filter haben alle Gerichte ausgeblendet.',
            )
          : ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, i) => MealCard(meal: meals[i]),
            ),
    };
  }
}
