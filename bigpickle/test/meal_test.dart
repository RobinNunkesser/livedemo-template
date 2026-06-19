import 'package:flutter_test/flutter_test.dart';
import 'package:campusflow/domain/meal.dart';

void main() {
  group('Meal', () {
    test('creates from actual OpenMensa API JSON format', () {
      final json = {
        'id': 336686,
        'name': 'Minestrone (A, A1, G, I)',
        'category': 'Suppe',
        'image':
            '//bilderspeiseplan.studentenwerk-dresden.de/m9/202606/336686.jpg',
        'prices': {'Studierende': 2.18, 'Bedienstete': 3.97},
        'notes': [
          'Menü ist vegetarisch',
          'Glutenhaltiges Getreide (A)',
          'Weizen (A1)',
          'Milch/Milchzucker (Laktose) (G)',
          'Sellerie (I)',
        ],
      };

      final meal = Meal.fromJson(json);

      expect(meal.id, 336686);
      expect(meal.name, 'Minestrone (A, A1, G, I)');
      expect(meal.category, 'Suppe');
      expect(
        meal.image,
        'https://bilderspeiseplan.studentenwerk-dresden.de/m9/202606/336686.jpg',
      );
      expect(meal.priceStudents, 2.18);
      expect(meal.priceEmployees, 3.97);
      expect(meal.bestPrice, 2.18);
      expect(meal.allergens, containsAll(['A', 'G', 'I']));
      expect(meal.allergens, isNot(contains('A1')));
      expect(meal.additives, isEmpty);
    });

    test('handles meal with additives in notes', () {
      final json = {
        'id': 336702,
        'name': 'Kartoffelpuffer',
        'category': 'Angebot 4',
        'prices': {'Studierende': 1.67, 'Bedienstete': 3.03},
        'notes': [
          'Menü ist vegetarisch',
          'mit Antioxydationsmittel (3)',
          'Eier (C)',
        ],
      };

      final meal = Meal.fromJson(json);
      expect(meal.allergens, contains('C'));
      expect(meal.additives, contains('3'));
    });

    test('handles missing optional fields', () {
      final json = {
        'id': 2,
        'name': 'Nudeln',
        'category': 'Vegetarisch',
        'prices': {'Studierende': 2.50},
      };

      final meal = Meal.fromJson(json);

      expect(meal.id, 2);
      expect(meal.name, 'Nudeln');
      expect(meal.image, isNull);
      expect(meal.allergens, isEmpty);
      expect(meal.additives, isEmpty);
    });

    test('hasImage returns true only when image is present', () {
      final withImage = Meal.fromJson({
        'id': 1,
        'name': 'Test',
        'category': 'Test',
        'prices': {'Studierende': 1.0},
        'image': 'https://example.com/img.jpg',
      });
      expect(withImage.hasImage, isTrue);

      final withoutImage = Meal.fromJson({
        'id': 2,
        'name': 'Test',
        'category': 'Test',
        'prices': {'Studierende': 1.0},
      });
      expect(withoutImage.hasImage, isFalse);
    });

    test('hasAnyAllergen checks correctly', () {
      final meal = Meal.fromJson({
        'id': 4,
        'name': 'Test',
        'category': 'Test',
        'prices': {'Studierende': 1.0},
        'notes': [
          'Glutenhaltiges Getreide (A)',
          'Eier (C)',
          'Milch/Laktose (G)',
        ],
      });

      expect(meal.hasAnyAllergen({'A'}), isTrue);
      expect(meal.hasAnyAllergen({'B'}), isFalse);
      expect(meal.hasAnyAllergen({'A', 'B'}), isTrue);
    });

    test('knownAllergens resolves codes to labels', () {
      final meal = Meal.fromJson({
        'id': 5,
        'name': 'Test',
        'category': 'Test',
        'prices': {'Studierende': 1.0},
        'notes': [
          'Glutenhaltiges Getreide (A)',
          'Milch/Laktose (G)',
          'Unknown (X)',
        ],
      });

      expect(meal.knownAllergens, contains('Glutenhaltiges Getreide'));
      expect(meal.knownAllergens, contains('Milch/Laktose'));
      expect(meal.knownAllergens, hasLength(2));
    });

    test('additives pattern matches numeric codes in notes', () {
      final meal = Meal.fromJson({
        'id': 6,
        'name': 'Test',
        'category': 'Test',
        'prices': {'Studierende': 1.0},
        'notes': ['mit Farbstoff (1)', 'mit Süßungsmittel (9)'],
      });

      expect(meal.knownAdditives, contains('mit Farbstoff'));
      expect(meal.knownAdditives, contains('mit Süßungsmittel'));
    });
  });
}
