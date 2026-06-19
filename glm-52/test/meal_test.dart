import 'package:campusflow/domain/allergens.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Meal', () {
    test('priceDisplay formatiert Studierendenpreis als Euro (A2)', () {
      final meal = Meal(
        id: 1,
        name: 'Curry',
        category: 'Angebot 1',
        priceStudent: 3.5,
      );
      expect(meal.priceDisplay, '€3,50');
    });

    test('priceDisplay fällt auf Bedienstetenpreis zurück', () {
      final meal = Meal(
        id: 2,
        name: 'Suppe',
        category: 'Suppe',
        priceStudent: null,
        priceEmployee: 4.07,
      );
      expect(meal.priceDisplay, '€4,07');
    });

    test('containsAnyAllergen erkennt Allergene (A4)', () {
      final meal = Meal(
        id: 3,
        name: 'Brot',
        category: 'Beilage',
        priceStudent: 1.0,
        allergens: const [
          Allergen(code: 'A', name: 'Glutenhaltiges Getreide'),
          Allergen(code: 'G', name: 'Milch'),
        ],
      );
      expect(meal.containsAnyAllergen({'A'}), isTrue);
      expect(meal.containsAnyAllergen({'G'}), isTrue);
      expect(meal.containsAnyAllergen({'D'}), isFalse);
      expect(meal.containsAnyAllergen({}), isFalse);
    });
  });

  group('FoodCategory.label', () {
    test('liefert lesbare Namen (A16)', () {
      expect(FoodCategory.fleisch.label, 'Fleisch');
      expect(FoodCategory.fisch.label, 'Fisch');
      expect(FoodCategory.vegetarisch.label, 'Vegetarisch');
      expect(FoodCategory.vegan.label, 'Vegan');
      expect(FoodCategory.sonstiges.label, 'Sonstiges');
    });
  });

  group('AllergenCatalog', () {
    test('enthält 14 EU-Hauptallergene (A4)', () {
      expect(AllergenCatalog.mainAllergens.length, 14);
    });

    test('byCode liefert lesbaren Namen (A5)', () {
      expect(AllergenCatalog.byCode('A')?.name, 'Glutenhaltiges Getreide');
      expect(AllergenCatalog.byCode('I')?.name, 'Sellerie');
      expect(AllergenCatalog.byCode('Z'), isNull); // unbekannt -> ignoriert
    });
  });
}
