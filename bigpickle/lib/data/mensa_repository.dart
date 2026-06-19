import '../domain/meal.dart';
import '../domain/mensa_day.dart';
import 'mensa_client.dart';

class MensaRepository {
  final MensaClient _client;

  MensaRepository(this._client);

  Future<List<MensaDay>> getDays() async {
    final response = await _client.getDays();
    final days = _client.parseDaysResponse(response);
    return days.map((d) => MensaDay.fromJson(d)).toList();
  }

  Future<List<Meal>> getMeals(String date) async {
    final response = await _client.getMeals(date);
    final meals = _client.parseMealsResponse(response);
    return meals.map((m) => Meal.fromJson(m)).where(_isValidMeal).toList();
  }

  bool _isValidMeal(Meal meal) {
    if (meal.id <= 0) return false;
    if (meal.name.isEmpty) return false;
    if (meal.category.isEmpty) return false;
    if (meal.bestPrice <= 0) return false;
    return true;
  }
}
