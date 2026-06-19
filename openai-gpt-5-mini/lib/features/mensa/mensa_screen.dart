import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mensa_provider.dart';
import 'models/meal.dart';
import '../../shared/widgets/loading.dart';
import '../../shared/widgets/error.dart';
import '../../shared/widgets/empty.dart';

class MensaScreen extends ConsumerWidget {
  const MensaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mensaMealsProvider);
    final savedAllergens = ref.watch(savedAllergensProvider);
    final isClosed = ref.watch(mensaClosedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mensa')),
      body: mealsAsync.when(
        data: (meals) {
          final filtered = _applyAllergenFilter(meals, savedAllergens);
          if (filtered.isEmpty) {
            if (isClosed) {
              return const EmptyWidget(
                  text:
                      '⚠️ Mensa heute geschlossen\n\nDie Mensa hat heute keine Öffnungszeiten.');
            }
            return const EmptyWidget(
                text: 'Heute sind keine Gerichte verfügbar.');
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) => _MealTile(meal: filtered[i]),
          );
        },
        loading: () => const LoadingWidget(message: 'Lade Mensaplan...'),
        error: (e, st) => ErrorWidgetBox(
            message: 'Mensa nicht verfügbar',
            onRetry: () => ref.read(mensaMealsProvider.notifier).refresh()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAllergenDialog(context, ref),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  List<Meal> _applyAllergenFilter(List<Meal> meals, List<String> allergens) {
    if (allergens.isEmpty) return meals;
    return meals
        .where((m) => !m.allergens.any((a) => allergens.contains(a)))
        .toList();
  }

  void _openAllergenDialog(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<List<String>>(
        context: context, builder: (c) => const _AllergenDialog());
    if (selected != null) {
      await ref.read(savedAllergensProvider.notifier).save(selected);
    }
  }
}

class _MealTile extends StatelessWidget {
  final Meal meal;
  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: meal.imageUrl != null
          ? Image.network(meal.imageUrl!,
              width: 56, height: 56, fit: BoxFit.cover)
          : const Icon(Icons.fastfood),
      title: Text(meal.name),
      subtitle: Text(meal.category),
      trailing:
          Text(meal.price != null ? '€${meal.price!.toStringAsFixed(2)}' : '-'),
    );
  }
}

class _AllergenDialog extends ConsumerStatefulWidget {
  const _AllergenDialog({super.key});

  @override
  ConsumerState<_AllergenDialog> createState() => _AllergenDialogState();
}

class _AllergenDialogState extends ConsumerState<_AllergenDialog> {
  static const _allergens = [
    'Glutenhaltiges Getreide',
    'Krebstiere',
    'Eier',
    'Fisch',
    'Erdnuesse',
    'Soja',
    'Milch/Laktose',
    'Schalenfruechte',
    'Sellerie',
    'Senf',
    'Sesam',
    'Schwefeldioxid/Sulfit',
    'Lupinen',
    'Weichtiere'
  ];
  final Set<String> _sel = {};

  @override
  void initState() {
    super.initState();
    _sel.addAll(ref.read(savedAllergensProvider));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Allergene filtern'),
      content: SingleChildScrollView(
        child: Column(
          children: _allergens
              .map((a) => CheckboxListTile(
                  value: _sel.contains(a),
                  onChanged: (v) =>
                      setState(() => v == true ? _sel.add(a) : _sel.remove(a)),
                  title: Text(a)))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Abbrechen')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(_sel.toList()),
            child: const Text('Speichern')),
      ],
    );
  }
}
