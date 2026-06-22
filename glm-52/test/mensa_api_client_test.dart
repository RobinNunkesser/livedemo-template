import 'dart:convert';

import 'package:campusflow/data/mensa_api_client.dart';
import 'package:campusflow/data/mensa_repository.dart';
import 'package:campusflow/domain/meal.dart' show FoodCategory;
import 'package:campusflow/domain/mensa_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MensaApiClient _client(http.Client client) =>
    MensaApiClient(client: client, timeout: const Duration(seconds: 2));

const _days = '[{"date":"2026-06-19","closed":false},'
    '{"date":"2026-06-20","closed":true}]';

const _meals = '[{'
    '"id":1,'
    '"name":"Veganer Auflauf",'
    '"category":"Angebot 1",'
    '"notes":["Menü ist vegan","Soja (F)"],'
    '"prices":{"Studierende":2.35},'
    '"image":"//bilderspeiseplan.example.de/1.jpg"'
    '},{'
    '"id":2,'
    '"name":"Schnitzel",'
    '"category":"Angebot 2",'
    '"notes":["enthält Schweinefleisch","Glutenhaltiges Getreide (A)"],'
    '"prices":{"Studierende":4.43,"Bedienstete":8.05}'
    '},{'
    // Ungültig: kein Preis -> wird verworfen (A9)
    '"id":3,'
    '"name":"Ohne Preis",'
    '"category":"Angebot 3",'
    '"prices":{}'
    '},{'
    // Ungültig: kein Name -> wird verworfen (A9)
    '"id":4,'
    '"name":"",'
    '"category":"Angebot 4",'
    '"prices":{"Studierende":1.0}'
    '}]';

void main() {
  group('MensaApiClient.getDay', () {
    test('Erfolgsfall: offener Tag mit gültigen Gerichten (A1, A2)', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/days')) {
          return http.Response(_days, 200);
        }
        return http.Response(_meals, 200);
      });
      final day = await _client(mock).getDay('2026-06-19');

      expect(day.status, DayStatus.open);
      expect(day.meals.length, 2); // 2 ungültige verworfen
      expect(day.meals.first.name, 'Veganer Auflauf');
      expect(day.meals.first.foodCategory.label, 'Vegan');
      expect(day.meals.first.priceDisplay, '€2,35');
      // Allergen wurde gelesen (A5)
      expect(day.meals.first.allergens.any((a) => a.code == 'F'), isTrue);
    });

    test('closed=true -> Geschlossen-Zustand (A7)', () async {
      final mock = MockClient((request) async {
        return http.Response(_days, 200);
      });
      final day = await _client(mock).getDay('2026-06-20');
      expect(day.status, DayStatus.closed);
      expect(day.meals, isEmpty);
    });

    test('kein Eintrag für heute -> Leerzustand (A7)', () async {
      final mock = MockClient((request) async {
        return http.Response(_days, 200);
      });
      final day = await _client(mock).getDay('1999-01-01');
      expect(day.status, DayStatus.noData);
    });

    test('5xx -> genau ein Retry, dann Fehler (A8)', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        return http.Response('Server Error', 500);
      });
      await expectLater(
        _client(mock).getDay('2026-06-19'),
        throwsA(isA<MensaRepositoryException>()),
      );
      // /days wird 2x gerufen (1 + Retry); /meals nicht erreicht.
      expect(calls, 2);
    });

    test('5xx erholt sich beim Retry -> Erfolg', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        if (calls == 1) {
          return http.Response('Server Error', 500);
        }
        return http.Response(_days, 200);
      });
      final day = await _client(mock).getDay('2026-06-19');
      expect(day.status, DayStatus.open);
      expect(calls, 2 + 1); // /days (1+Retry) + /meals (1)
    });

    test('4xx -> kein Retry (A8)', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        return http.Response('Not Found', 404);
      });
      await expectLater(
        _client(mock).getDay('2026-06-19'),
        throwsA(isA<MensaRepositoryException>()),
      );
      expect(calls, 1);
    });

    test('Netzwerkfehler -> genau ein Retry (A8)', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        throw http.ClientException('Connection refused');
      });
      await expectLater(
        _client(mock).getDay('2026-06-19'),
        throwsA(isA<MensaRepositoryException>()),
      );
      expect(calls, 2);
    });

    test('Ungültige Meals werden verworfen (A9)', () async {
      final meals = jsonEncode([
        {
          'id': 1,
          'name': 'OK',
          'category': 'X',
          'prices': {'Studierende': 1},
        },
        {
          'id': 2,
          'name': '',
          'category': 'X',
          'prices': {'Studierende': 1},
        },
        {'id': 3, 'name': 'Kein Preis', 'category': 'X', 'prices': {}},
        {
          'category': 'X',
          'prices': {'Studierende': 1},
        },
      ]);
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/days')) {
          return http.Response(_days, 200);
        }
        return http.Response(meals, 200);
      });
      final day = await _client(mock).getDay('2026-06-19');
      expect(day.meals.length, 1);
    });

    test('Fleisch-Erkennung über notes (A16)', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/days')) {
          return http.Response(_days, 200);
        }
        return http.Response(_meals, 200);
      });
      final day = await _client(mock).getDay('2026-06-19');
      final schnitzel = day.meals.firstWhere((m) => m.name == 'Schnitzel');
      expect(schnitzel.foodCategory, FoodCategory.fleisch);
    });

    test('Image-URL mit //-Präfix wird zu https: normalisiert (A3)', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/days')) {
          return http.Response(_days, 200);
        }
        return http.Response(_meals, 200);
      });
      final day = await _client(mock).getDay('2026-06-19');
      expect(
        day.meals.first.imageUrl,
        'https://bilderspeiseplan.example.de/1.jpg',
      );
    });
  });
}
