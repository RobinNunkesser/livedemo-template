import 'package:flutter_test/flutter_test.dart';
import 'package:campusflow/domain/meal.dart';

void main() {
  group('Meal', () {
    test('isValid returns true when all required fields are present', () {
      final meal = Meal(
        id: 1,
        name: 'Schnitzel',
        category: 'Fleisch',
        prices: {'students': 3.50},
      );

      expect(meal.isValid(), isTrue);
    });

    test('isValid returns false when id is 0', () {
      final meal = Meal(
        id: 0,
        name: 'Schnitzel',
        category: 'Fleisch',
        prices: {'students': 3.50},
      );

      expect(meal.isValid(), isFalse);
    });

    test('isValid returns false when name is empty', () {
      final meal = Meal(
        id: 1,
        name: '',
        category: 'Fleisch',
        prices: {'students': 3.50},
      );

      expect(meal.isValid(), isFalse);
    });

    test('isValid returns false when no valid price', () {
      final meal = Meal(
        id: 1,
        name: 'Schnitzel',
        category: 'Fleisch',
        prices: {'students': null},
      );

      expect(meal.isValid(), isFalse);
    });

    test('fromJson creates valid Meal from JSON', () {
      final json = {
        'id': 123,
        'name': 'Schnitzel',
        'category': 'Fleisch',
        'prices': {'students': 3.50},
        'allergens': ['Gluten'],
      };

      final meal = Meal.fromJson(json);

      expect(meal.id, 123);
      expect(meal.name, 'Schnitzel');
      expect(meal.category, 'Fleisch');
      expect(meal.allergens, ['Gluten']);
    });
  });
}
