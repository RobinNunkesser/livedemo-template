import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:campusflow/data/providers.dart';
import 'package:campusflow/data/mensa_repository.dart';
import 'package:campusflow/domain/meal.dart';
import 'package:campusflow/domain/mensa_day.dart';
import 'package:campusflow/features/mensaplan/mensaplan_screen.dart';

class MockMensaRepository implements MensaRepository {
  int getDaysCallCount = 0;
  bool shouldThrowOnGetDays = false;
  List<MensaDay> daysResult = [];
  List<Meal> mealsResult = [];

  @override
  Future<List<MensaDay>> getDays(int canteenId) async {
    getDaysCallCount++;
    if (shouldThrowOnGetDays) {
      throw Exception('Mock network error');
    }
    return daysResult;
  }

  @override
  Future<List<Meal>> getMeals(int canteenId, String dateStr) async {
    return mealsResult;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de_DE', null);
  });

  group('MensaplanScreen Widget Tests', () {
    late MockMensaRepository mockRepository;
    late SharedPreferences mockPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      mockRepository = MockMensaRepository();
    });

    testWidgets('Should display error state when repository throws error and retry reloading', (WidgetTester tester) async {
      mockRepository.shouldThrowOnGetDays = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            mensaRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MensaplanScreen(),
            ),
          ),
        ),
      );

      // Render initial loading frame, then settle to error state
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Error state is shown
      expect(find.text('Fehler beim Laden'), findsOneWidget);
      expect(find.text('Neu laden'), findsOneWidget);
      expect(mockRepository.getDaysCallCount, 1);

      // Set repository to succeed on next call
      mockRepository.shouldThrowOnGetDays = false;
      mockRepository.daysResult = [MensaDay(date: DateTime.now(), closed: false)];
      mockRepository.mealsResult = [
        Meal(
          id: 1,
          name: 'Vegan Curry',
          category: 'Angebot 1',
          studentPrice: 2.50,
          employeePrice: 4.00,
          allergens: [],
          additives: [],
          dietaryType: 'Vegan',
        )
      ];

      // Tap 'Neu laden' button
      await tester.tap(find.text('Neu laden'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify repository was called again
      expect(mockRepository.getDaysCallCount, 2);
      expect(find.text('Vegan Curry'), findsOneWidget);
    });

    testWidgets('Should display empty state when there are no meals for today', (WidgetTester tester) async {
      mockRepository.daysResult = [MensaDay(date: DateTime.now(), closed: false)];
      mockRepository.mealsResult = []; // No meals

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            mensaRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MensaplanScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Keine Gerichte'), findsOneWidget);
      expect(find.text('Für heute sind keine Gerichte eingetragen.'), findsOneWidget);
    });

    testWidgets('Should display closed state when mensa is closed today', (WidgetTester tester) async {
      mockRepository.daysResult = [MensaDay(date: DateTime.now(), closed: true)];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            mensaRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MensaplanScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Mensa heute geschlossen'), findsOneWidget);
      expect(find.text('Die Mensa hat heute leider kein Angebot (z. B. am Wochenende oder Feiertag).'), findsOneWidget);
    });
  });
}
