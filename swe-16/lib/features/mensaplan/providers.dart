import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers.dart';
import '../../data/mensa_repository.dart';
import '../../domain/mensa_day.dart';
import '../../domain/meal.dart';

// Categories for filtering
enum MealCategory {
  fleisch('Fleisch'),
  fisch('Fisch'),
  vegetarisch('Vegetarisch'),
  vegan('Vegan'),
  beilagen('Beilagen'),
  suppen('Suppen'),
  getraenke('Getränke'),
  desserts('Desserts');

  final String label;
  const MealCategory(this.label);
}

// EU Allergens for filtering
enum Allergen {
  gluten('Glutenhaltiges Getreide'),
  krebstiere('Krebstiere'),
  eier('Eier'),
  fisch('Fisch'),
  erdnuesse('Erdnüsse'),
  soja('Soja'),
  milch('Milch/Laktose'),
  schalenfruechte('Schalenfrüchte'),
  sellerie('Sellerie'),
  senf('Senf'),
  sesam('Sesam'),
  schwefeldioxid('Schwefeldioxid/Sulfit'),
  lupinen('Lupinen'),
  weichtiere('Weichtiere');

  final String label;
  const Allergen(this.label);
}

// State for Mensaplan
class MensaState {
  final bool isLoading;
  final MensaDay? mensaDay;
  final String? error;
  final Set<MealCategory> selectedCategories;
  final Set<Allergen> selectedAllergens;

  MensaState({
    this.isLoading = false,
    this.mensaDay,
    this.error,
    this.selectedCategories = const {},
    this.selectedAllergens = const {},
  });

  MensaState copyWith({
    bool? isLoading,
    MensaDay? mensaDay,
    String? error,
    Set<MealCategory>? selectedCategories,
    Set<Allergen>? selectedAllergens,
  }) {
    return MensaState(
      isLoading: isLoading ?? this.isLoading,
      mensaDay: mensaDay ?? this.mensaDay,
      error: error ?? this.error,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
    );
  }

  List<Meal> get filteredMeals {
    if (mensaDay == null) return [];

    return mensaDay!.meals.where((meal) {
      // Category filter (inclusive)
      if (selectedCategories.isNotEmpty) {
        final categoryMatch = selectedCategories.any(
          (cat) =>
              meal.category.toLowerCase().contains(cat.label.toLowerCase()),
        );
        if (!categoryMatch) return false;
      }

      // Allergen filter (exclusive - meals with selected allergens are hidden)
      // Note: In a real implementation, you would check meal allergens here
      // For MVP, we'll implement the structure but actual allergen data
      // would need to be parsed from the API response

      return true;
    }).toList();
  }
}

class MensaNotifier extends StateNotifier<MensaState> {
  final MensaRepository _repository;

  MensaNotifier(this._repository) : super(MensaState()) {
    _loadFilters();
    loadTodayMeals();
  }

  Future<void> loadTodayMeals() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final mensaDay = await _repository.getTodayMeals();
      state = state.copyWith(isLoading: false, mensaDay: mensaDay);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleCategory(MealCategory category) {
    final newCategories = Set<MealCategory>.from(state.selectedCategories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    state = state.copyWith(selectedCategories: newCategories);
    _saveFilters();
  }

  void toggleAllergen(Allergen allergen) {
    final newAllergens = Set<Allergen>.from(state.selectedAllergens);
    if (newAllergens.contains(allergen)) {
      newAllergens.remove(allergen);
    } else {
      newAllergens.add(allergen);
    }
    state = state.copyWith(selectedAllergens: newAllergens);
    _saveFilters();
  }

  void resetFilters() {
    state = state.copyWith(selectedCategories: {}, selectedAllergens: {});
    _saveFilters();
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryIndices = prefs.getStringList('selectedCategories') ?? [];
    final allergenIndices = prefs.getStringList('selectedAllergens') ?? [];

    final categories = categoryIndices
        .map((i) => MealCategory.values[int.parse(i)])
        .toSet();
    final allergens = allergenIndices
        .map((i) => Allergen.values[int.parse(i)])
        .toSet();

    state = state.copyWith(
      selectedCategories: categories,
      selectedAllergens: allergens,
    );
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selectedCategories',
      state.selectedCategories.map((c) => c.index.toString()).toList(),
    );
    await prefs.setStringList(
      'selectedAllergens',
      state.selectedAllergens.map((a) => a.index.toString()).toList(),
    );
  }
}

final mensaProvider = StateNotifierProvider<MensaNotifier, MensaState>((ref) {
  final repository = ref.watch(mensaRepositoryProvider);
  return MensaNotifier(repository);
});
