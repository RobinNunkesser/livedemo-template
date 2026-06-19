import '../domain/meal.dart';
import '../domain/mensa_day.dart';
import 'mensa_client.dart';

abstract class MensaRepository {
  Future<List<MensaDay>> getDays(int canteenId);
  Future<List<Meal>> getMeals(int canteenId, String dateStr);
}

class MensaRepositoryImpl implements MensaRepository {
  final MensaClient _client;

  MensaRepositoryImpl(this._client);

  @override
  Future<List<MensaDay>> getDays(int canteenId) async {
    try {
      final List<dynamic> data = await _client.getDays(canteenId);
      return data.map((json) => MensaDay.fromJson(json)).toList();
    } catch (e) {
      print('Repository: Failed to load days: $e');
      rethrow;
    }
  }

  @override
  Future<List<Meal>> getMeals(int canteenId, String dateStr) async {
    try {
      final List<dynamic> data = await _client.getMeals(canteenId, dateStr);
      final List<Meal> meals = [];

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          try {
            final meal = Meal.fromJson(item);
            meals.add(meal);
          } catch (e) {
            // Discard invalid record silently and log internally
            print('Repository: Silently discarding invalid meal record. Error: $e. Data: $item');
          }
        } else {
          print('Repository: Silently discarding invalid meal record (not a Map). Data: $item');
        }
      }
      return meals;
    } catch (e) {
      print('Repository: Failed to load meals: $e');
      rethrow;
    }
  }
}
