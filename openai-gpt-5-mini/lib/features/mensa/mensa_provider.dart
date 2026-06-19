import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mensa_service.dart';
import 'models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

final mensaServiceProvider = Provider((ref) => MensaService());
final mensaMealsProvider =
    StateNotifierProvider<MensaMealsNotifier, AsyncValue<List<Meal>>>(
        (ref) => MensaMealsNotifier(ref));

final mensaClosedProvider = StateProvider<bool>((ref) => false);

class MensaMealsNotifier extends StateNotifier<AsyncValue<List<Meal>>> {
  final Ref ref;
  MensaMealsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadToday();
  }

  Future<void> loadToday() async {
    state = const AsyncValue.loading();
    try {
      final svc = ref.read(mensaServiceProvider);
      final today = DateTime.now();
      final yyyy = today.year.toString().padLeft(4, '0');
      final mm = today.month.toString().padLeft(2, '0');
      final dd = today.day.toString().padLeft(2, '0');
      final date = '$yyyy-$mm-$dd';
      // check closed flag for today
      final closed = await svc.isClosedForDate(date);
      // update provider flag for UI
      ref.read(mensaClosedProvider.notifier).state = closed;
      if (closed) {
        state = const AsyncValue.data([]);
        return;
      }
      final meals = await svc.fetchMealsForDate(date);
      state = AsyncValue.data(meals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => loadToday();
}

final savedAllergensProvider =
    StateNotifierProvider<SavedAllergensNotifier, List<String>>(
        (ref) => SavedAllergensNotifier());

class SavedAllergensNotifier extends StateNotifier<List<String>> {
  SavedAllergensNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('allergens') ?? [];
  }

  Future<void> save(List<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergens', allergens);
    state = allergens;
  }
}
