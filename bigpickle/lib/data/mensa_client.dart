import 'dart:convert';
import 'package:http/http.dart' as http;

class MensaClient {
  final http.Client _client;
  final String baseUrl;
  final int canteenId;

  MensaClient({
    http.Client? client,
    this.baseUrl = 'https://api.studentenwerk-dresden.de/openmensa/v2',
    this.canteenId = 6,
  }) : _client = client ?? http.Client();

  Future<http.Response> getDays() async {
    final uri = Uri.parse('$baseUrl/canteens/$canteenId/days');
    return _client.get(uri).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> getMeals(String date) async {
    final uri = Uri.parse('$baseUrl/canteens/$canteenId/days/$date/meals');
    return _client.get(uri).timeout(const Duration(seconds: 5));
  }

  Map<String, dynamic> _parseDaysBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        final days = decoded.cast<Map<String, dynamic>>();
        return {'days': days};
      }
      return {'days': []};
    } catch (_) {
      return {'days': []};
    }
  }

  List<Map<String, dynamic>> parseDaysResponse(http.Response response) {
    if (response.statusCode != 200) return [];
    final result = _parseDaysBody(response.body);
    return List<Map<String, dynamic>>.from(result['days'] ?? []);
  }

  List<Map<String, dynamic>> parseMealsResponse(http.Response response) {
    if (response.statusCode != 200) return [];
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
