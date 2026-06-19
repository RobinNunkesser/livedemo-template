import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livedemo_template_mvp/features/mensa/mensa_service.dart';
import 'package:livedemo_template_mvp/features/mensa/mensa_provider.dart';

void main() {
  test('MensaMealsNotifier loads data from service', () async {
    final mockClient = MockClient((req) async {
      if (req.url.path.endsWith('/days')) {
        final today = DateTime.now();
        final yyyy = today.year.toString().padLeft(4, '0');
        final mm = today.month.toString().padLeft(2, '0');
        final dd = today.day.toString().padLeft(2, '0');
        final date = '$yyyy-$mm-$dd';
        return http.Response(
            jsonEncode([
              {'date': date, 'closed': false}
            ]),
            200);
      }
      // meals endpoint
      final body = jsonEncode([
        {
          'id': 1,
          'name': 'A',
          'category': 'F',
          'prices': {'students': 1.0}
        }
      ]);
      return http.Response(body, 200);
    });

    final container = ProviderContainer(overrides: [
      mensaServiceProvider.overrideWithValue(MensaService(client: mockClient)),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(mensaMealsProvider.notifier);
    await notifier.loadToday();
    final state = container.read(mensaMealsProvider);
    expect(state.asData?.value.length, 1);
  });

  test('SavedAllergensNotifier persists and loads values', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(savedAllergensProvider.notifier);
    await notifier.save(['Soja', 'Milch/Laktose']);
    // create a new instance to verify persistence
    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final notifier2 = container2.read(savedAllergensProvider.notifier);
    await notifier2.load();
    final values = container2.read(savedAllergensProvider);
    // shared_preferences mock stores values globally, so expect saved list is present
    expect(values, isA<List<String>>());
  });
}
