import 'package:shared_preferences/shared_preferences.dart';

import '../domain/filter_settings.dart';

/// Persistiert Mensaplan-Filtereinstellungen lokal auf dem Gerät.
/// Laut ADR-003 / Feature-Mensaplan AF 1D.
class FilterPersistence {
  static const _keyAllergens = 'mensa_filter_allergens';
  static const _keyCategories = 'mensa_filter_categories';

  Future<FilterSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final allergens =
        Set<String>.from(prefs.getStringList(_keyAllergens) ?? []);
    final categories =
        Set<String>.from(prefs.getStringList(_keyCategories) ?? []);
    return FilterSettings(
      selectedAllergens: allergens,
      selectedCategories: categories,
    );
  }

  Future<void> save(FilterSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keyAllergens, settings.selectedAllergens.toList());
    await prefs.setStringList(
        _keyCategories, settings.selectedCategories.toList());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAllergens);
    await prefs.remove(_keyCategories);
  }
}
