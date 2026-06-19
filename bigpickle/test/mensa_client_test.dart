import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:campusflow/data/mensa_client.dart';

void main() {
  group('MensaClient', () {
    test('parseDaysResponse returns list from valid response', () {
      final client = MensaClient();
      final response = http.Response(
        '[{"date": "2026-06-19", "closed": false}]',
        200,
      );
      final days = client.parseDaysResponse(response);
      expect(days, hasLength(1));
      expect(days[0]['date'], '2026-06-19');
      expect(days[0]['closed'], false);
    });

    test('parseMealsResponse returns list from valid response', () {
      final client = MensaClient();
      final response = http.Response(
        '[{"id": 1, "name": "Test", "category": "Vegan", "prices": {"Studierende": 2.5}}]',
        200,
      );
      final meals = client.parseMealsResponse(response);
      expect(meals, hasLength(1));
      expect(meals[0]['id'], 1);
    });

    test('parseDaysResponse returns empty list on error status', () {
      final client = MensaClient();
      final response = http.Response('Not Found', 404);
      final days = client.parseDaysResponse(response);
      expect(days, isEmpty);
    });

    test('parseMealsResponse returns empty list on error status', () {
      final client = MensaClient();
      final response = http.Response('Server Error', 500);
      final meals = client.parseMealsResponse(response);
      expect(meals, isEmpty);
    });

    test('parseDaysResponse returns empty list on invalid JSON', () {
      final client = MensaClient();
      final response = http.Response('not json', 200);
      final days = client.parseDaysResponse(response);
      expect(days, isEmpty);
    });
  });
}
