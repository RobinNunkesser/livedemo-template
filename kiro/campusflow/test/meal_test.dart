import 'package:campusflow/domain/meal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Meal.fromJson', () {
    test('valides Gericht wird korrekt geparst', () {
      final json = {
        'id': 1,
        'name': 'Hähnchen-Curry',
        'category': 'Fleisch',
        'prices': {'students': 2.5, 'employees': 3.5},
        'notes': ['Gl', 'Mi'],
      };

      final meal = Meal.fromJson(json);

      expect(meal, isNotNull);
      expect(meal!.id, 1);
      expect(meal.name, 'Hähnchen-Curry');
      expect(meal.category, 'Fleisch');
      expect(meal.displayPrice, 2.5);
      expect(meal.allergens, contains('Glutenhaltiges Getreide'));
      expect(meal.allergens, contains('Milch/Laktose'));
    });

    test('Gericht ohne id wird verworfen', () {
      final json = {
        'name': 'Suppe',
        'category': 'Suppen',
        'prices': {'students': 1.0},
      };
      expect(Meal.fromJson(json), isNull);
    });

    test('Gericht mit leerem name wird verworfen', () {
      final json = {
        'id': 2,
        'name': '',
        'category': 'Suppen',
        'prices': {'students': 1.0},
      };
      expect(Meal.fromJson(json), isNull);
    });

    test('Gericht ohne Preis wird verworfen', () {
      final json = {
        'id': 3,
        'name': 'Salat',
        'category': 'Vegetarisch',
        'prices': <String, dynamic>{},
      };
      expect(Meal.fromJson(json), isNull);
    });

    test('Gericht mit nur employees-Preis ist valide', () {
      final json = {
        'id': 4,
        'name': 'Pizza',
        'category': 'Sonstiges',
        'prices': {'employees': 4.0},
      };
      final meal = Meal.fromJson(json);
      expect(meal, isNotNull);
      expect(meal!.displayPrice, 4.0);
    });

    test('Gericht mit image URL wird korrekt geparst', () {
      final json = {
        'id': 5,
        'name': 'Pasta',
        'category': 'Vegetarisch',
        'prices': {'students': 1.8},
        'image': 'https://example.com/pasta.jpg',
      };
      final meal = Meal.fromJson(json);
      expect(meal!.imageUrl, 'https://example.com/pasta.jpg');
    });

    test('Gericht mit leerem image bekommt null imageUrl', () {
      final json = {
        'id': 6,
        'name': 'Reis',
        'category': 'Beilagen',
        'prices': {'students': 0.5},
        'image': '',
      };
      final meal = Meal.fromJson(json);
      expect(meal!.imageUrl, isNull);
    });

    test('Unbekannte Allergen-Codes werden ignoriert', () {
      final json = {
        'id': 7,
        'name': 'Gericht',
        'category': 'Sonstiges',
        'prices': {'students': 2.0},
        'notes': ['XX', 'YY', 'Ei'], // XX und YY sind unbekannt
      };
      final meal = Meal.fromJson(json);
      expect(meal!.allergens, ['Eier']);
    });

    test('Alle 14 EU-Hauptallergene sind bekannt', () {
      final labels = Meal.allAllergenLabels;
      expect(labels.length, 14);
    });

    test('displayPrice bevorzugt Studierendenpreis', () {
      final json = {
        'id': 8,
        'name': 'Gericht',
        'category': 'Sonstiges',
        'prices': {'students': 2.0, 'employees': 3.5, 'others': 4.0},
      };
      final meal = Meal.fromJson(json);
      expect(meal!.displayPrice, 2.0);
    });
  });

  group('MealPrices', () {
    test('hasAnyPrice ist false wenn alle Preise null', () {
      const prices = MealPrices();
      expect(prices.hasAnyPrice, isFalse);
    });

    test('hasAnyPrice ist true wenn mindestens ein Preis gesetzt', () {
      const prices = MealPrices(pupils: 1.5);
      expect(prices.hasAnyPrice, isTrue);
    });
  });
}
