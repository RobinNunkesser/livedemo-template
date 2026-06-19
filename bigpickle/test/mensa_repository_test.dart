import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:campusflow/data/mensa_client.dart';
import 'package:campusflow/data/mensa_repository.dart';

void main() {
  group('MensaRepository', () {
    test('getDays returns parsed days', () async {
      final mock = MockClient((request) async {
        return http.Response('[{"date": "2026-06-19", "closed": false}]', 200);
      });
      final client = MensaClient(client: mock);
      final repo = MensaRepository(client);

      final days = await repo.getDays();
      expect(days, hasLength(1));
      expect(days[0].closed, isFalse);
    });

    test('getMeals filters invalid meals', () async {
      final mock = MockClient((request) async {
        return http.Response(
          '[{"id": 1, "name": "Valid Meal", "category": "Vegan", "prices": {"Studierende": 2.5}}, {"id": 0, "name": "", "category": "", "prices": {}}]',
          200,
        );
      });
      final client = MensaClient(client: mock);
      final repo = MensaRepository(client);

      final meals = await repo.getMeals('2026-06-19');
      expect(meals, hasLength(1));
      expect(meals[0].name, 'Valid Meal');
    });

    test('getMeals returns empty list when API returns empty', () async {
      final mock = MockClient((request) async {
        return http.Response('[]', 200);
      });
      final client = MensaClient(client: mock);
      final repo = MensaRepository(client);

      final meals = await repo.getMeals('2026-06-19');
      expect(meals, isEmpty);
    });
  });
}
