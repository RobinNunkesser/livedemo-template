import 'dart:convert';

import 'package:campusflow/data/mensa_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MensaClient.getDays', () {
    test('Erfolgsfall: Tage werden korrekt geparst', () async {
      final client = MensaClient(
        client: MockClient((request) async {
          expect(request.url.path, contains('/days'));
          return http.Response(
            jsonEncode([
              {'date': '2026-06-19', 'closed': false},
              {'date': '2026-06-20', 'closed': true},
            ]),
            200,
          );
        }),
      );

      final days = await client.getDays();

      expect(days.length, 2);
      expect(days[0].date, '2026-06-19');
      expect(days[0].closed, isFalse);
      expect(days[1].closed, isTrue);
    });

    test('HTTP 503 löst MensaException aus', () async {
      var callCount = 0;
      final client = MensaClient(
        client: MockClient((request) async {
          callCount++;
          return http.Response('Server Error', 503);
        }),
      );

      await expectLater(
        () => client.getDays(),
        throwsA(isA<MensaException>().having(
          (e) => e.kind,
          'kind',
          MensaErrorKind.http,
        )),
      );
      // Genau 2 Versuche (1 + 1 Retry) laut TechDesign-Mensaplan.md
      expect(callCount, 2);
    });

    test('HTTP 404 löst sofort aus ohne Retry', () async {
      var callCount = 0;
      final client = MensaClient(
        client: MockClient((request) async {
          callCount++;
          return http.Response('Not Found', 404);
        }),
      );

      await expectLater(
        () => client.getDays(),
        throwsA(isA<MensaException>().having(
          (e) => e.kind,
          'kind',
          MensaErrorKind.http,
        )),
      );
      // Kein Retry bei 4xx
      expect(callCount, 1);
    });
  });

  group('MensaClient.getMealsForDay', () {
    test('Valide Mahlzeiten werden geparst', () async {
      final client = MensaClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'name': 'Hähnchen-Curry',
                'category': 'Fleisch',
                'prices': {'students': 2.5},
                'notes': ['Mi'],
              },
              {
                'id': 2,
                'name': 'Gemüsepfanne',
                'category': 'Vegetarisch',
                'prices': {'students': 1.8},
              },
            ]),
            200,
          );
        }),
      );

      final meals = await client.getMealsForDay('2026-06-19');

      expect(meals.length, 2);
      expect(meals[0].name, 'Hähnchen-Curry');
      expect(meals[1].category, 'Vegetarisch');
    });

    test('Ungültige Mahlzeiten werden stillschweigend verworfen', () async {
      final client = MensaClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              // Valide
              {
                'id': 1,
                'name': 'Suppe',
                'category': 'Suppen',
                'prices': {'students': 1.0},
              },
              // Ungültig: kein Preis
              {
                'id': 2,
                'name': 'Kein Preis',
                'category': 'Sonstiges',
                'prices': <String, dynamic>{},
              },
              // Ungültig: kein Name
              {
                'id': 3,
                'name': '',
                'category': 'Sonstiges',
                'prices': {'students': 2.0},
              },
            ]),
            200,
          );
        }),
      );

      final meals = await client.getMealsForDay('2026-06-19');

      // Nur 1 valide Mahlzeit
      expect(meals.length, 1);
      expect(meals[0].name, 'Suppe');
    });
  });
}
