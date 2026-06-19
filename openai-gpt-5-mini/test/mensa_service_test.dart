import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:livedemo_template_mvp/features/mensa/mensa_service.dart';

void main() {
  test('fetchMealsForDate returns parsed meals and filters invalid entries',
      () async {
    final mockClient = MockClient((req) async {
      final body = jsonEncode([
        {
          'id': 1,
          'name': 'Hähnchen-Curry mit Reis',
          'category': 'Fleisch',
          'prices': {'students': 3.5},
          'image': null,
          'allergens': ['Soja']
        },
        {
          // invalid: missing name
          'id': 2,
          'category': 'Vegetarisch',
          'prices': {'students': 2.5}
        }
      ]);
      return http.Response(body, 200);
    });

    final svc = MensaService(client: mockClient);
    final meals = await svc.fetchMealsForDate('2026-06-19');
    expect(meals.length, 1);
    expect(meals.first.name, contains('Hähnchen'));
  });

  test('fetchMealsForDate throws on non-200', () async {
    final mockClient = MockClient((req) async => http.Response('error', 500));
    final svc = MensaService(client: mockClient);
    expect(
        () async => await svc.fetchMealsForDate('2026-06-19'), throwsException);
  });
}
