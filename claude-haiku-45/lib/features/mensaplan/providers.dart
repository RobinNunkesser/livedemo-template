import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/mensa_day.dart';
import '../../domain/meal.dart';
import '../../data/providers.dart';
import '../../data/mensa_repository.dart';

/// State for Mensaplan loading
class MensaState {
  final MensaDay? day;
  final bool isLoading;
  final String? error;
  final bool isClosed;

  MensaState({
    this.day,
    this.isLoading = false,
    this.error,
    this.isClosed = false,
  });

  MensaState copyWith({
    MensaDay? day,
    bool? isLoading,
    String? error,
    bool? isClosed,
  }) {
    return MensaState(
      day: day ?? this.day,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

/// StateNotifier for Mensaplan
class MensaNotifier extends StateNotifier<MensaState> {
  final IMensaRepository _repository;

  MensaNotifier(this._repository) : super(MensaState());

  Future<void> loadMeals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final day = await _repository.getMealsForToday();
      if (day == null) {
        state = state.copyWith(isLoading: false, error: null, day: null);
      } else if (day.closed) {
        state = state.copyWith(isLoading: false, isClosed: true, day: day);
      } else {
        state = state.copyWith(isLoading: false, day: day, isClosed: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider for Mensaplan state
final mensaProvider = StateNotifierProvider<MensaNotifier, MensaState>((ref) {
  final repository = ref.watch(mensaRepositoryProvider);
  return MensaNotifier(repository);
});

/// Filter state
class FilterState {
  final List<String> selectedCategories;
  final List<String> selectedAllergens;

  FilterState({
    this.selectedCategories = const [],
    this.selectedAllergens = const [],
  });

  FilterState copyWith({
    List<String>? selectedCategories,
    List<String>? selectedAllergens,
  }) {
    return FilterState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
    );
  }
}

/// StateNotifier for filter management
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void toggleCategory(String category) {
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  void toggleAllergen(String allergen) {
    final allergens = List<String>.from(state.selectedAllergens);
    if (allergens.contains(allergen)) {
      allergens.remove(allergen);
    } else {
      allergens.add(allergen);
    }
    state = state.copyWith(selectedAllergens: allergens);
  }

  void resetFilters() {
    state = FilterState();
  }
}

/// Provider for filter state
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});

/// Filtered meals provider
final filteredMealsProvider = Provider<List<Meal>>((ref) {
  final mensaState = ref.watch(mensaProvider);
  final filters = ref.watch(filterProvider);

  if (mensaState.day == null || mensaState.day!.meals.isEmpty) {
    return [];
  }

  var filtered = List<Meal>.from(mensaState.day!.meals);

  // Apply allergen filter (hide meals with selected allergens)
  if (filters.selectedAllergens.isNotEmpty) {
    filtered = filtered.where((meal) {
      final hasAllergen = filters.selectedAllergens.any(
        (allergen) => meal.allergens.contains(allergen),
      );
      return !hasAllergen;
    }).toList();
  }

  // Apply category filter (inclusive)
  if (filters.selectedCategories.isNotEmpty) {
    filtered = filtered.where((meal) {
      return filters.selectedCategories.contains(meal.category);
    }).toList();
  }

  return filtered;
});
