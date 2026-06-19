/// Nutzereinstellungen für den Mensaplan-Filter.
/// Wird lokal persistiert (SharedPreferences).
class FilterSettings {
  const FilterSettings({
    this.selectedAllergens = const {},
    this.selectedCategories = const {},
  });

  /// Allergen-Labels, die ausgeblendet werden sollen (exklusiv).
  final Set<String> selectedAllergens;

  /// Kategorie-Labels, die angezeigt werden sollen (inklusiv).
  /// Wenn leer → alle Kategorien anzeigen.
  final Set<String> selectedCategories;

  bool get hasActiveFilters =>
      selectedAllergens.isNotEmpty || selectedCategories.isNotEmpty;

  FilterSettings copyWith({
    Set<String>? selectedAllergens,
    Set<String>? selectedCategories,
  }) {
    return FilterSettings(
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  FilterSettings clearAll() =>
      const FilterSettings(selectedAllergens: {}, selectedCategories: {});
}
