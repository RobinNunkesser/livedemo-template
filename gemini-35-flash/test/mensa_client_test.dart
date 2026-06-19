import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campusflow/data/mensa_client.dart';
import 'package:campusflow/data/mensa_repository.dart';

void main() {
  group('MensaClient Tests', () {
    test('Should return data successfully on 200 OK', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('[{"date":"2026-06-19","closed":false}]', 200);
      });

      final client = MensaClient(client: mockHttpClient);
      final days = await client.getDays(6);

      expect(days.length, 1);
      expect(days[0]['date'], '2026-06-19');
    });

    test('Should retry exactly once on 500 error and succeed if retry succeeds', () async {
      int attemptCount = 0;
      final mockHttpClient = MockClient((request) async {
        attemptCount++;
        if (attemptCount == 1) {
          return http.Response('Server Error', 500);
        }
        return http.Response('[{"date":"2026-06-19","closed":false}]', 200);
      });

      final client = MensaClient(client: mockHttpClient);
      final days = await client.getDays(6);

      expect(attemptCount, 2);
      expect(days.length, 1);
    });

    test('Should throw exception if both first attempt and retry fail with 500', () async {
      int attemptCount = 0;
      final mockHttpClient = MockClient((request) async {
        attemptCount++;
        return http.Response('Server Error', 500);
      });

      final client = MensaClient(client: mockHttpClient);

      await expectLater(client.getDays(6), throwsA(isA<http.ClientException>()));
      expect(attemptCount, 2); // 1 original + 1 retry
    });

    test('Should NOT retry on 404 client error', () async {
      int attemptCount = 0;
      final mockHttpClient = MockClient((request) async {
        attemptCount++;
        return http.Response('Not Found', 404);
      });

      final client = MensaClient(client: mockHttpClient);

      await expectLater(client.getDays(6), throwsA(isA<http.ClientException>()));
      expect(attemptCount, 1); // No retry for 4xx
    });

    test('Should retry on timeout and throw if retry also fails', () async {
      int attemptCount = 0;
      final mockHttpClient = MockClient((request) async {
        attemptCount++;
        // First attempt timeouts, second attempt throws client exception
        if (attemptCount == 1) {
          throw TimeoutException('Timeout');
        }
        throw http.ClientException('Network Error');
      });

      final client = MensaClient(client: mockHttpClient);

      await expectLater(client.getDays(6), throwsA(isA<http.ClientException>()));
      expect(attemptCount, 2); // 1 timeout + 1 retry
    });
  });

  group('MensaRepository Tests', () {
    test('Should parse valid meals and silently discard invalid meals', () async {
      final jsonResponse = '''
      [
        {
          "id": 1,
          "name": "Valid Meal",
          "category": "Main",
          "prices": {"students": 2.5}
        },
        {
          "id": 2,
          "name": "Invalid Meal (No prices)",
          "category": "Main",
          "prices": {}
        },
        {
          "name": "Invalid Meal (No ID)",
          "category": "Main",
          "prices": {"students": 2.5}
        }
      ]
      ''';

      final mockHttpClient = MockClient((request) async {
        return http.Response(jsonResponse, 200);
      });

      final client = MensaClient(client: mockHttpClient);
      final repo = MensaRepositoryImpl(client);

      final meals = await repo.getMeals(6, '2026-06-19');

      expect(meals.length, 1);
      expect(meals[0].name, 'Valid Meal');
    });
  });
}
