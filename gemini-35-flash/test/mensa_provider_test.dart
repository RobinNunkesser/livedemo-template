import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusflow/data/providers.dart';
import 'package:campusflow/data/mensa_repository.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:campusflow/domain/mensa_day.dart';
import 'package:campusflow/features/mensaplan/providers.dart';

class FakeMensaRepository implements MensaRepository {
  final List<MensaDay> days;
  final List<Meal> meals;

  FakeMensaRepository({required this.days, required this.meals});

  @override
  Future<List<MensaDay>> getDays(int canteenId) async => days;

  @override
  Future<List<Meal>> getMeals(int canteenId, String dateStr) async => meals;
}

void main() {
  group('Mensa Riverpod Providers Tests', () {
    late FakeMensaRepository fakeRepository;
    late SharedPreferences fakePrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      fakePrefs = await SharedPreferences.getInstance();

      final today = DateTime.now();
      fakeRepository = FakeMensaRepository(
        days: [MensaDay(date: today, closed: false)],
        meals: [
          Meal(
            id: 1,
            name: 'Schnitzel (A, C, G)',
            category: 'Angebot 1',
            studentPrice: 3.50,
            employeePrice: 4.50,
            allergens: ['Glutenhaltiges Getreide', 'Eier', 'Milch/Laktose'],
            additives: [],
            dietaryType: 'Fleisch',
          ),
          Meal(
            id: 2,
            name: 'Vegan Chili (F)',
            category: 'Angebot 2',
            studentPrice: 2.30,
            employeePrice: 3.90,
            allergens: ['Soja'],
            additives: ['Künstliche Farbstoffe'],
            dietaryType: 'Vegan',
          ),
          Meal(
            id: 3,
            name: 'Kaiserschmarrn (A, C, G)',
            category: 'Angebot 3',
            studentPrice: 2.80,
            employeePrice: 4.00,
            allergens: ['Glutenhaltiges Getreide', 'Eier', 'Milch/Laktose'],
            additives: [],
            dietaryType: 'Vegetarisch',
          ),
        ],
      );
    });

    test('Initial loading fetches meals and applies empty filters', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          mensaRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      // Wait for it to finish loading
      await container.read(mensaStateProvider.notifier).loadMeals();

      final loadedState = container.read(mensaStateProvider);
      expect(loadedState.status, MensaScreenStatus.loaded);
      expect(loadedState.allMeals.length, 3);
      expect(loadedState.filteredMeals.length, 3);
    });

    test('Applying category filter Veggie shows Veggie and Vegan, but hides Meat', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          mensaRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaStateProvider.notifier).loadMeals();

      // Apply filter: "Vegetarisch"
      final filterNotifier = container.read(mensaFilterProvider.notifier);
      await filterNotifier.saveFilters(MensaFilter(
        categories: ['Vegetarisch'],
        avoidAllergens: [],
        avoidAdditives: [],
      ));

      final state = container.read(mensaStateProvider);
      expect(state.filteredMeals.length, 2);
      expect(state.filteredMeals.map((m) => m.name), containsAll(['Vegan Chili (F)', 'Kaiserschmarrn (A, C, G)']));
      expect(state.filteredMeals.map((m) => m.name), isNot(contains('Schnitzel (A, C, G)')));
    });

    test('Allergen avoidance hides matching meals', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          mensaRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaStateProvider.notifier).loadMeals();

      // Avoid "Milch/Laktose"
      final filterNotifier = container.read(mensaFilterProvider.notifier);
      await filterNotifier.saveFilters(MensaFilter(
        categories: [],
        avoidAllergens: ['Milch/Laktose'],
        avoidAdditives: [],
      ));

      final state = container.read(mensaStateProvider);
      expect(state.filteredMeals.length, 1);
      expect(state.filteredMeals[0].name, 'Vegan Chili (F)');
    });

    test('Combined filter logic (AND logic between category and allergen avoidance)', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          mensaRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(mensaStateProvider.notifier).loadMeals();

      // Want: Vegetarisch, Avoid: Soja
      final filterNotifier = container.read(mensaFilterProvider.notifier);
      await filterNotifier.saveFilters(MensaFilter(
        categories: ['Vegetarisch'],
        avoidAllergens: ['Soja'],
        avoidAdditives: [],
      ));

      final state = container.read(mensaStateProvider);
      // Vegan Chili has Soja, so it gets hidden. Only Kaiserschmarrn matches.
      expect(state.filteredMeals.length, 1);
      expect(state.filteredMeals[0].name, 'Kaiserschmarrn (A, C, G)');
    });
  });
}
