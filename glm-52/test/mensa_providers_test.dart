import 'package:campusflow/data/mensa_repository.dart';
import 'package:campusflow/domain/allergens.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:campusflow/domain/mensa_day.dart';
import 'package:campusflow/features/mensaplan/filter_state.dart';
import 'package:campusflow/features/mensaplan/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake-Repository mit festem Datenbestand für Provider-Tests.
class FakeMensaRepository implements MensaRepository {
  FakeMensaRepository(this._day);
  final MensaDay _day;

  @override
  Future<MensaDay> getDay(String date) async => _day;
}

MensaDay _dayWith(List<Meal> meals) =>
    MensaDay(date: '2026-06-19', status: DayStatus.open, meals: meals);

void main() {
  group('filteredMealsProvider', () {
    test('Allergen-Filter blendet betroffene Gerichte aus (A4)', () async {
      final meals = [
        Meal(
          id: 1,
          name: 'Mit Gluten',
          category: 'X',
          priceStudent: 1,
          allergens: const [Allergen(code: 'A', name: 'Gluten')],
        ),
        Meal(id: 2, name: 'Sauber', category: 'X', priceStudent: 2),
      ];
      final container = ProviderContainer(
        overrides: [
          mensaProvider.overrideWith(
            (ref) => MensaNotifier(FakeMensaRepository(_dayWith(meals))),
          ),
          filterProvider.overrideWith(
            (ref) => FilterNotifier(_InMemoryStorage()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaProvider.notifier).load();
      await container.read(filterProvider.notifier).setAllergens({'A'});

      final result = container.read(filteredMealsProvider);
      expect(result.length, 1);
      expect(result.first.name, 'Sauber');
    });

    test('Kategorie-Filter arbeitet inklusiv (A16)', () async {
      final meals = [
        Meal(
          id: 1,
          name: 'Veganes Curry',
          category: 'X',
          priceStudent: 1,
          foodCategory: FoodCategory.vegan,
        ),
        Meal(
          id: 2,
          name: 'Schnitzel',
          category: 'X',
          priceStudent: 2,
          foodCategory: FoodCategory.fleisch,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          mensaProvider.overrideWith(
            (ref) => MensaNotifier(FakeMensaRepository(_dayWith(meals))),
          ),
          filterProvider.overrideWith(
            (ref) => FilterNotifier(_InMemoryStorage()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaProvider.notifier).load();
      await container
          .read(filterProvider.notifier)
          .setCategories({FoodCategory.vegan.name});

      final result = container.read(filteredMealsProvider);
      expect(result.length, 1);
      expect(result.first.foodCategory, FoodCategory.vegan);
    });

    test('Kombinierte Filter mit AND-Logik (A12)', () async {
      // Vegan UND kein Soja -> nur "Sauber" überlebt.
      final meals = [
        Meal(
          id: 1,
          name: 'Vegan mit Soja',
          category: 'X',
          priceStudent: 1,
          foodCategory: FoodCategory.vegan,
          allergens: const [Allergen(code: 'F', name: 'Soja')],
        ),
        Meal(
          id: 2,
          name: 'Vegan sauber',
          category: 'X',
          priceStudent: 2,
          foodCategory: FoodCategory.vegan,
        ),
        Meal(
          id: 3,
          name: 'Fleisch',
          category: 'X',
          priceStudent: 3,
          foodCategory: FoodCategory.fleisch,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          mensaProvider.overrideWith(
            (ref) => MensaNotifier(FakeMensaRepository(_dayWith(meals))),
          ),
          filterProvider.overrideWith(
            (ref) => FilterNotifier(_InMemoryStorage()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaProvider.notifier).load();
      await container
          .read(filterProvider.notifier)
          .setCategories({FoodCategory.vegan.name});
      await container.read(filterProvider.notifier).setAllergens({'F'});

      final result = container.read(filteredMealsProvider);
      expect(result.length, 1);
      expect(result.first.name, 'Vegan sauber');
    });
  });
}

class _InMemoryStorage implements FilterStorage {
  FilterState _state = const FilterState();
  @override
  Future<FilterState> load() async => _state;
  @override
  Future<void> save(FilterState s) async {
    _state = s;
  }
}
