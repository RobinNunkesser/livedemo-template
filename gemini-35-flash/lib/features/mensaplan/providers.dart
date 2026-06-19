import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers.dart';
import '../../data/mensa_repository.dart';
import '../../domain/meal.dart';

class MensaFilter {
  final List<String> categories;
  final List<String> avoidAllergens;
  final List<String> avoidAdditives;

  MensaFilter({
    required this.categories,
    required this.avoidAllergens,
    required this.avoidAdditives,
  });

  MensaFilter copyWith({
    List<String>? categories,
    List<String>? avoidAllergens,
    List<String>? avoidAdditives,
  }) {
    return MensaFilter(
      categories: categories ?? this.categories,
      avoidAllergens: avoidAllergens ?? this.avoidAllergens,
      avoidAdditives: avoidAdditives ?? this.avoidAdditives,
    );
  }

  MensaFilter.empty()
      : categories = [],
        avoidAllergens = [],
        avoidAdditives = [];
}

class MensaFilterNotifier extends StateNotifier<MensaFilter> {
  final SharedPreferences _prefs;
  static const _keyCategories = 'mensa_filter_categories';
  static const _keyAllergens = 'mensa_filter_allergens';
  static const _keyAdditives = 'mensa_filter_additives';

  MensaFilterNotifier(this._prefs) : super(MensaFilter.empty()) {
    _loadFilters();
  }

  void _loadFilters() {
    final categories = _prefs.getStringList(_keyCategories) ?? [];
    final allergens = _prefs.getStringList(_keyAllergens) ?? [];
    final additives = _prefs.getStringList(_keyAdditives) ?? [];
    state = MensaFilter(
      categories: categories,
      avoidAllergens: allergens,
      avoidAdditives: additives,
    );
  }

  Future<void> saveFilters(MensaFilter filter) async {
    state = filter;
    await _prefs.setStringList(_keyCategories, filter.categories);
    await _prefs.setStringList(_keyAllergens, filter.avoidAllergens);
    await _prefs.setStringList(_keyAdditives, filter.avoidAdditives);
  }

  Future<void> resetFilters() async {
    state = MensaFilter.empty();
    await _prefs.remove(_keyCategories);
    await _prefs.remove(_keyAllergens);
    await _prefs.remove(_keyAdditives);
  }
}

enum MensaScreenStatus {
  loading,
  error,
  empty,
  closed,
  loaded,
}

class MensaState {
  final MensaScreenStatus status;
  final List<Meal> allMeals;
  final List<Meal> filteredMeals;
  final String? errorMessage;

  MensaState({
    required this.status,
    required this.allMeals,
    required this.filteredMeals,
    this.errorMessage,
  });

  MensaState copyWith({
    MensaScreenStatus? status,
    List<Meal>? allMeals,
    List<Meal>? filteredMeals,
    String? errorMessage,
  }) {
    return MensaState(
      status: status ?? this.status,
      allMeals: allMeals ?? this.allMeals,
      filteredMeals: filteredMeals ?? this.filteredMeals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  MensaState.initial()
      : status = MensaScreenStatus.loading,
        allMeals = [],
        filteredMeals = [],
        errorMessage = null;
}

class MensaNotifier extends StateNotifier<MensaState> {
  final MensaRepository _repository;
  final MensaFilter _filter;
  final int canteenId = 6;

  MensaNotifier(this._repository, this._filter) : super(MensaState.initial()) {
    loadMeals();
  }

  Future<void> loadMeals() async {
    state = state.copyWith(status: MensaScreenStatus.loading, errorMessage: null);
    try {
      final days = await _repository.getDays(canteenId);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final todayDay = days.firstWhere(
        (day) => DateFormat('yyyy-MM-dd').format(day.date) == todayStr,
        orElse: () => throw StateError('No day for today'),
      );

      if (todayDay.closed) {
        state = state.copyWith(status: MensaScreenStatus.closed, allMeals: [], filteredMeals: []);
        return;
      }

      final meals = await _repository.getMeals(canteenId, todayStr);
      if (meals.isEmpty) {
        state = state.copyWith(status: MensaScreenStatus.empty, allMeals: [], filteredMeals: []);
      } else {
        final filtered = _applyFilters(meals, _filter);
        state = state.copyWith(
          status: filtered.isEmpty ? MensaScreenStatus.empty : MensaScreenStatus.loaded,
          allMeals: meals,
          filteredMeals: filtered,
        );
      }
    } catch (e) {
      if (e is StateError && e.message == 'No day for today') {
        state = state.copyWith(status: MensaScreenStatus.empty, allMeals: [], filteredMeals: []);
      } else {
        state = state.copyWith(
          status: MensaScreenStatus.error,
          errorMessage: e.toString(),
          allMeals: [],
          filteredMeals: [],
        );
      }
    }
  }

  void updateFilters(MensaFilter newFilter) {
    if (state.status == MensaScreenStatus.loaded || state.status == MensaScreenStatus.empty) {
      final filtered = _applyFilters(state.allMeals, newFilter);
      state = state.copyWith(
        status: filtered.isEmpty ? MensaScreenStatus.empty : MensaScreenStatus.loaded,
        filteredMeals: filtered,
      );
    }
  }

  List<Meal> _applyFilters(List<Meal> meals, MensaFilter filter) {
    return meals.where((meal) {
      // Category filter (inclusive OR among selected categories)
      if (filter.categories.isNotEmpty) {
        final matches = filter.categories.any((cat) {
          if (cat == 'Vegan' && meal.dietaryType == 'Vegan') return true;
          if (cat == 'Vegetarisch' && (meal.dietaryType == 'Vegetarisch' || meal.dietaryType == 'Vegan')) return true;
          if (cat == 'Fleisch' && meal.dietaryType == 'Fleisch') return true;
          return false;
        });
        if (!matches) return false;
      }

      // Allergen filter (exclusive AND - hide if meal contains any of avoided allergens)
      if (filter.avoidAllergens.isNotEmpty) {
        final containsAvoided = meal.allergens.any((all) => filter.avoidAllergens.contains(all));
        if (containsAvoided) return false;
      }

      // Additive filter (exclusive AND - hide if meal contains any of avoided additives)
      if (filter.avoidAdditives.isNotEmpty) {
        final containsAvoided = meal.additives.any((add) => filter.avoidAdditives.contains(add));
        if (containsAvoided) return false;
      }

      return true;
    }).toList();
  }
}

final mensaFilterProvider = StateNotifierProvider<MensaFilterNotifier, MensaFilter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MensaFilterNotifier(prefs);
});

final mensaStateProvider = StateNotifierProvider<MensaNotifier, MensaState>((ref) {
  final repo = ref.watch(mensaRepositoryProvider);
  final filter = ref.watch(mensaFilterProvider);
  final notifier = MensaNotifier(repo, filter);

  ref.listen<MensaFilter>(mensaFilterProvider, (previous, next) {
    notifier.updateFilters(next);
  });

  return notifier;
});
