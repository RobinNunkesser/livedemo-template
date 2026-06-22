import 'package:intl/intl.dart';
import 'mensa_client.dart';
import '../domain/mensa_day.dart';

class MensaRepository {
  final MensaClient _client;

  MensaRepository({MensaClient? client}) : _client = client ?? MensaClient();

  Future<MensaDay> getTodayMeals() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      return await _client.getMealsForDay(today);
    } catch (e) {
      throw Exception('Failed to load today\'s meals: $e');
    }
  }

  Future<bool> isCanteenOpenToday() async {
    try {
      final days = await _client.getDays();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final todayData = days.firstWhere(
        (day) => day['date'] == today,
        orElse: () => {'closed': true},
      );

      return !(todayData['closed'] as bool? ?? true);
    } catch (e) {
      return false;
    }
  }
}
