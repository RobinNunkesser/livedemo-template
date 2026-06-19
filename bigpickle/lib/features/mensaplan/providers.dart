import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers.dart';
import '../../domain/meal.dart';

enum MensaState { initial, loading, loaded, error, closed, noMeals }

class MensaplanState {
  final MensaState state;
  final List<Meal> allMeals;
  final String? errorMessage;
  final Set<String> selectedAllergens;
  final Set<String> selectedCategories;

  const MensaplanState({
    this.state = MensaState.initial,
    this.allMeals = const [],
    this.errorMessage,
    this.selectedAllergens = const {},
    this.selectedCategories = const {},
  });

  MensaplanState copyWith({
    MensaState? state,
    List<Meal>? allMeals,
    String? errorMessage,
    Set<String>? selectedAllergens,
    Set<String>? selectedCategories,
  }) {
    return MensaplanState(
      state: state ?? this.state,
      allMeals: allMeals ?? this.allMeals,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  List<Meal> get filteredMeals {
    var result = allMeals;
    if (selectedCategories.isNotEmpty) {
      result = result
          .where((m) => selectedCategories.contains(m.category))
          .toList();
    }
    if (selectedAllergens.isNotEmpty) {
      result = result
          .where((m) => !m.hasAnyAllergen(selectedAllergens))
          .toList();
    }
    return result;
  }
}

class MensaplanNotifier extends StateNotifier<MensaplanState> {
  final Ref _ref;

  MensaplanNotifier(this._ref) : super(const MensaplanState());

  Future<void> loadMensaplan() async {
    state = state.copyWith(state: MensaState.loading, errorMessage: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAllergens = prefs.getStringList('mensa_allergens') ?? [];
      final savedCategories = prefs.getStringList('mensa_categories') ?? [];

      state = state.copyWith(
        selectedAllergens: savedAllergens.toSet(),
        selectedCategories: savedCategories.toSet(),
      );

      final repository = _ref.read(mensaRepositoryProvider);
      final today = DateTime.now();
      final dateStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final days = await repository.getDays();
      final todayDay = days
          .where(
            (d) =>
                d.date.year == today.year &&
                d.date.month == today.month &&
                d.date.day == today.day,
          )
          .toList();

      if (todayDay.isEmpty) {
        state = state.copyWith(state: MensaState.noMeals);
        return;
      }

      if (todayDay.first.closed) {
        state = state.copyWith(state: MensaState.closed);
        return;
      }

      final meals = await repository.getMeals(dateStr);
      if (meals.isEmpty) {
        state = state.copyWith(state: MensaState.noMeals);
        return;
      }

      state = state.copyWith(state: MensaState.loaded, allMeals: meals);
    } catch (e) {
      state = state.copyWith(
        state: MensaState.error,
        errorMessage:
            'Die Daten konnten gerade nicht geladen werden. Bitte später versuchen.',
      );
    }
  }

  Future<void> setAllergens(Set<String> allergens) async {
    state = state.copyWith(selectedAllergens: allergens);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mensa_allergens', allergens.toList());
  }

  Future<void> setCategories(Set<String> categories) async {
    state = state.copyWith(selectedCategories: categories);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mensa_categories', categories.toList());
  }

  Future<void> resetFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mensa_allergens');
    await prefs.remove('mensa_categories');
    state = state.copyWith(selectedAllergens: {}, selectedCategories: {});
  }
}

final mensaplanProvider =
    StateNotifierProvider<MensaplanNotifier, MensaplanState>((ref) {
      return MensaplanNotifier(ref);
    });
