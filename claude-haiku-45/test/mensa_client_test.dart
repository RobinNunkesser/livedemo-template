import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';

import 'package:campusflow/data/mensa_client.dart';

void main() {
  group('OpenMensaClient', () {
    test('getMealsForToday returns null when no data for today', () async {
      final client = OpenMensaClient(
        httpClient: MockClient((_) async {
          return http.Response('[]', 200);
        }),
      );

      final result = await client.getMealsForToday();

      expect(result, isNull);
    });

    test('getMealsForToday returns closed state when closed=true', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final client = OpenMensaClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/days')) {
            return http.Response('[{"date":"$today","closed":true}]', 200);
          }
          return http.Response('[]', 200);
        }),
      );

      final result = await client.getMealsForToday();

      expect(result, isNotNull);
      expect(result!.closed, isTrue);
    });

    test('getMealsForToday handles 5xx with retry', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var callCount = 0;

      final client = OpenMensaClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/days')) {
            callCount++;
            if (callCount == 1) {
              return http.Response('Server Error', 500);
            }
            return http.Response('[{"date":"$today","closed":true}]', 200);
          }
          return http.Response('[]', 200);
        }),
      );

      await client.getMealsForToday();

      expect(callCount, 2);
    });

    test('getMealsForToday throws on 4xx without retry', () async {
      var callCount = 0;
      final client = OpenMensaClient(
        httpClient: MockClient((_) async {
          callCount++;
          return http.Response('Not Found', 404);
        }),
      );

      await expectLater(
        () => client.getMealsForToday(),
        throwsA(isA<HttpException>()),
      );
      expect(callCount, 1);
    });

    test('getMealsForToday throws TimeoutException on timeout', () async {
      final client = OpenMensaClient(
        httpClient: MockClient((_) async {
          throw TimeoutException('simulated timeout');
        }),
      );

      await expectLater(
        () => client.getMealsForToday(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
