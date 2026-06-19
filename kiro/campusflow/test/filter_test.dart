import 'package:campusflow/domain/filter_settings.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:campusflow/features/mensaplan/providers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hilfsfunktion: erstellt Testmahlzeiten ohne JSON-Parsing
Meal _makeMeal({
  int id = 1,
  String name = 'Testgericht',
  String category = 'Fleisch',
  double price = 2.5,
  List<String> allergens = const [],
}) {
  return Meal(
    id: id,
    name: name,
    category: category,
    prices: MealPrices(students: price),
    allergens: allergens,
  );
}

void main() {
  group('applyFilters', () {
    final meals = [
      _makeMeal(
        id: 1,
        name: 'Hähnchen',
        category: 'Fleisch',
        allergens: ['Glutenhaltiges Getreide', 'Milch/Laktose'],
      ),
      _makeMeal(
        id: 2,
        name: 'Gemüsepfanne',
        category: 'Vegetarisch',
        allergens: ['Eier'],
      ),
      _makeMeal(
        id: 3,
        name: 'Linsencurry',
        category: 'Vegan',
        allergens: [],
      ),
      _makeMeal(
        id: 4,
        name: 'Fischfilet',
        category: 'Fisch',
        allergens: ['Fisch', 'Glutenhaltiges Getreide'],
      ),
    ];

    test('Keine Filter → alle Mahlzeiten werden angezeigt', () {
      final result = applyFilters(meals, const FilterSettings());
      expect(result.length, 4);
    });

    test('Allergen-Filter blendet betroffene Mahlzeiten aus', () {
      final filters = FilterSettings(
        selectedAllergens: {'Glutenhaltiges Getreide'},
      );
      final result = applyFilters(meals, filters);

      // Hähnchen (Gl) und Fischfilet (Gl) werden ausgeblendet
      expect(result.length, 2);
      expect(result.any((m) => m.name == 'Hähnchen'), isFalse);
      expect(result.any((m) => m.name == 'Fischfilet'), isFalse);
    });

    test('Kategorie-Filter zeigt nur gewählte Kategorien', () {
      final filters = FilterSettings(
        selectedCategories: {'Vegetarisch', 'Vegan'},
      );
      final result = applyFilters(meals, filters);

      expect(result.length, 2);
      expect(result.every((m) =>
          m.category == 'Vegetarisch' || m.category == 'Vegan'), isTrue);
    });

    test('AND-Logik: Allergen + Kategorie kombiniert', () {
      final filters = FilterSettings(
        selectedAllergens: {'Eier'}, // Gemüsepfanne ausblenden
        selectedCategories: {'Vegetarisch', 'Vegan'}, // nur diese Kategorien
      );
      final result = applyFilters(meals, filters);

      // Gemüsepfanne hat Ei → ausgeblendet; Linsencurry (Vegan, kein Ei) → ok
      expect(result.length, 1);
      expect(result[0].name, 'Linsencurry');
    });

    test('Mehrere Allergene filtern kumulativ', () {
      final filters = FilterSettings(
        selectedAllergens: {'Eier', 'Fisch'},
      );
      final result = applyFilters(meals, filters);

      // Gemüsepfanne (Ei), Fischfilet (Fisch) ausgeblendet
      expect(result.length, 2);
      expect(result.any((m) => m.name == 'Gemüsepfanne'), isFalse);
      expect(result.any((m) => m.name == 'Fischfilet'), isFalse);
    });

    test('Leere selectedCategories zeigt alle Kategorien', () {
      final filters = FilterSettings(
        selectedCategories: {},
      );
      final result = applyFilters(meals, filters);
      expect(result.length, 4);
    });
  });

  group('FilterSettings', () {
    test('hasActiveFilters ist false bei leeren Filtern', () {
      expect(const FilterSettings().hasActiveFilters, isFalse);
    });

    test('hasActiveFilters ist true wenn Allergen gesetzt', () {
      const filters = FilterSettings(selectedAllergens: {'Eier'});
      expect(filters.hasActiveFilters, isTrue);
    });

    test('clearAll setzt alle Filter zurück', () {
      const filters = FilterSettings(
        selectedAllergens: {'Eier'},
        selectedCategories: {'Vegan'},
      );
      final cleared = filters.clearAll();
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('copyWith behält andere Werte', () {
      const filters = FilterSettings(
        selectedAllergens: {'Eier'},
        selectedCategories: {'Vegan'},
      );
      final updated = filters.copyWith(selectedAllergens: {'Milch/Laktose'});
      expect(updated.selectedAllergens, {'Milch/Laktose'});
      expect(updated.selectedCategories, {'Vegan'}); // unverändert
    });
  });
}
