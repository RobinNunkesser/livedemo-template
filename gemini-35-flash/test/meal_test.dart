import 'package:flutter_test/flutter_test.dart';
import 'package:campusflow/domain/meal.dart';

void main() {
  group('Meal Model Tests', () {
    test('Should parse valid Meal JSON successfully', () {
      final json = {
        'id': 12345,
        'name': 'Hähnchen-Curry (A, G)',
        'category': 'Angebot 1',
        'notes': [
          'enthält Geflügelfleisch',
          'Glutenhaltiges Getreide (A)',
          'Milch/Milchzucker (Laktose) (G)'
        ],
        'prices': {
          'Studierende': 3.50,
          'Bedienstete': 4.50,
        },
        'image': '//bilderspeiseplan.de/123.jpg'
      };

      final meal = Meal.fromJson(json);

      expect(meal.id, 12345);
      expect(meal.name, 'Hähnchen-Curry (A, G)');
      expect(meal.category, 'Angebot 1');
      expect(meal.studentPrice, 3.50);
      expect(meal.employeePrice, 4.50);
      expect(meal.imageUrl, 'https://bilderspeiseplan.de/123.jpg');
      expect(meal.allergens, containsAll(['Glutenhaltiges Getreide', 'Milch/Laktose']));
      expect(meal.dietaryType, 'Fleisch');
    });

    test('Should support English price keys (students, employees)', () {
      final json = {
        'id': 12345,
        'name': 'Pasta',
        'category': 'Nudeln',
        'prices': {
          'students': 2.10,
          'employees': 3.90,
        }
      };

      final meal = Meal.fromJson(json);
      expect(meal.studentPrice, 2.10);
      expect(meal.employeePrice, 3.90);
    });

    test('Should parse allergens and additives properly and ignore unknown codes', () {
      final json = {
        'id': 111,
        'name': 'Vegan Bowl (A1, 1, 9)',
        'category': 'Teller',
        'notes': [
          'Menü ist vegan',
          'Weizen (A1)',
          'mit Farbstoff (1)',
          'mit Süßungsmittel (9)' // Unknown/ignored additive filter
        ],
        'prices': {'Studierende': 2.50}
      };

      final meal = Meal.fromJson(json);
      expect(meal.dietaryType, 'Vegan');
      expect(meal.allergens, contains('Glutenhaltiges Getreide'));
      expect(meal.additives, contains('Künstliche Farbstoffe'));
      expect(meal.additives, isNot(contains('mit Süßungsmittel')));
    });

    test('Should throw ArgumentError on missing ID', () {
      final json = {
        'name': 'Pasta',
        'category': 'Nudeln',
        'prices': {'students': 2.0}
      };

      expect(() => Meal.fromJson(json), throwsArgumentError);
    });

    test('Should throw ArgumentError on empty name', () {
      final json = {
        'id': 123,
        'name': '  ',
        'category': 'Nudeln',
        'prices': {'students': 2.0}
      };

      expect(() => Meal.fromJson(json), throwsArgumentError);
    });

    test('Should throw ArgumentError on empty category', () {
      final json = {
        'id': 123,
        'name': 'Pasta',
        'category': '',
        'prices': {'students': 2.0}
      };

      expect(() => Meal.fromJson(json), throwsArgumentError);
    });

    test('Should throw ArgumentError when both prices are missing or invalid', () {
      final json = {
        'id': 123,
        'name': 'Pasta',
        'category': 'Nudeln',
        'prices': {'students': 0.0, 'employees': -1.0}
      };

      expect(() => Meal.fromJson(json), throwsArgumentError);
    });
  });
}
