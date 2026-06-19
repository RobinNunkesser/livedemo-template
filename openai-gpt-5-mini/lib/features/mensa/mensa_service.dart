import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/meal.dart';

class MensaService {
  final http.Client client;
  static const base = 'https://api.studentenwerk-dresden.de/openmensa/v2';
  static const canteenId = '6';

  MensaService({http.Client? client}) : client = client ?? http.Client();

  /// Deprecated placeholder removed. Use [fetchDays] / [isClosedForDate].

  Future<List<Meal>> fetchMealsForDate(String yyyyMmDd) async {
    final url = '$base/canteens/$canteenId/days/$yyyyMmDd/meals';
    final res =
        await client.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) throw Exception('API ${res.statusCode}');
    final data = jsonDecode(res.body) as List<dynamic>;
    final meals = data
        .map((m) {
          try {
            return Meal.fromJson(m as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Meal>()
        .toList();
    return meals;
  }

  /// Returns list of day objects from the API (`/canteens/{id}/days`).
  Future<List<Map<String, dynamic>>> fetchDays() async {
    final url = '$base/canteens/$canteenId/days';
    final res =
        await client.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) throw Exception('API ${res.statusCode}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((d) => d as Map<String, dynamic>).toList();
  }

  /// Checks if the canteen is marked closed for the given date (yyyy-mm-dd).
  Future<bool> isClosedForDate(String yyyyMmDd) async {
    final days = await fetchDays();
    final today = days.firstWhere((d) => (d['date'] as String?) == yyyyMmDd,
        orElse: () => {});
    if (today.isEmpty) return false; // no explicit entry -> treat as not-closed
    final closed = today['closed'];
    if (closed is bool) return closed;
    if (closed is String) return closed.toLowerCase() == 'true';
    return false;
  }
}
