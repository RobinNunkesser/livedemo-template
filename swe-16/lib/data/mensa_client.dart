import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/mensa_day.dart';

class MensaClient {
  final String baseUrl = 'https://api.studentenwerk-dresden.de/openmensa/v2';
  final int canteenId = 6;
  final Duration timeout = const Duration(seconds: 5);

  Future<List<Map<String, dynamic>>> getDays() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/canteens/$canteenId/days'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load days: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<MensaDay> getMealsForDay(String date) async {
    int retryCount = 0;
    const maxRetries = 1;

    while (retryCount <= maxRetries) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/canteens/$canteenId/days/$date/meals'))
            .timeout(timeout);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return MensaDay.fromJson(data);
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          // Don't retry on 4xx errors
          throw Exception('Client error: ${response.statusCode}');
        } else {
          // Retry on 5xx errors
          retryCount++;
          if (retryCount > maxRetries) {
            throw Exception('Server error: ${response.statusCode}');
          }
        }
      } on TimeoutException {
        retryCount++;
        if (retryCount > maxRetries) {
          throw Exception('Request timeout');
        }
      } catch (e) {
        retryCount++;
        if (retryCount > maxRetries) {
          throw Exception('Network error: $e');
        }
      }
    }

    throw Exception('Max retries exceeded');
  }
}
