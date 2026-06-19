/// Persistente Speicherung der Mensaplan-Filter (A14/A15).
///
/// Nutzt SharedPreferences als Port; das Interface erlaubt Tests mit Fakes.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Zustand der Mensa-Filter (Allergene + Kategorien).
class FilterState {
  const FilterState({
    this.hiddenAllergens = const {},
    this.selectedCategories = const {},
  });

  /// Codes der Allergene/Zusatzstoffe, die ausgeblendet werden sollen.
  final Set<String> hiddenAllergens;

  /// Gewählte Speise-Kategorien (inklusiver Filter); leer = alle.
  final Set<String> selectedCategories;

  FilterState copyWith({
    Set<String>? hiddenAllergens,
    Set<String>? selectedCategories,
  }) {
    return FilterState(
      hiddenAllergens: hiddenAllergens ?? this.hiddenAllergens,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  bool get isEmpty => hiddenAllergens.isEmpty && selectedCategories.isEmpty;
}

/// Port: Persistiert Filter lokal (A14) und lädt sie beim Start (A15).
abstract interface class FilterStorage {
  Future<FilterState> load();
  Future<void> save(FilterState state);
}

/// Adapter auf Basis von SharedPreferences.
class SharedPreferencesFilterStorage implements FilterStorage {
  SharedPreferencesFilterStorage(this._prefs);

  static const _keyAllergens = 'filter_hidden_allergens';
  static const _keyCategories = 'filter_selected_categories';

  final SharedPreferences _prefs;

  @override
  Future<FilterState> load() async {
    final allergens = _prefs.getStringList(_keyAllergens) ?? const [];
    final categories = _prefs.getStringList(_keyCategories) ?? const [];
    return FilterState(
      hiddenAllergens: allergens.toSet(),
      selectedCategories: categories.toSet(),
    );
  }

  @override
  Future<void> save(FilterState state) async {
    await _prefs.setStringList(_keyAllergens, state.hiddenAllergens.toList());
    await _prefs.setStringList(
      _keyCategories,
      state.selectedCategories.toList(),
    );
  }
}
