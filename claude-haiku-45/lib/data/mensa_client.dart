import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

import '../domain/mensa_day.dart';
import '../domain/meal.dart';

/// HTTP client for OpenMensa API
class OpenMensaClient {
  static const String baseUrl =
      'https://api.studentenwerk-dresden.de/openmensa/v2';
  static const int canteenId = 6;
  static const Duration requestTimeout = Duration(seconds: 5);

  final http.Client _httpClient;

  OpenMensaClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Get meals for today
  /// Throws OpenMensaException on error
  Future<MensaDay?> getMealsForToday() async {
    try {
      // Step 1: Get all days to find today's date
      final daysResponse = await _makeRequest(
        'GET',
        '$baseUrl/canteens/$canteenId/days',
      );

      final days = (jsonDecode(daysResponse) as List<dynamic>)
          .map((d) => Map<String, dynamic>.from(d as Map))
          .toList();

      // Step 2: Find today's date (yyyy-MM-dd format)
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final matchingDays = days.where((d) => d['date'] == todayStr).toList();
      if (matchingDays.isEmpty) {
        return null; // No data for today
      }
      final todayData = matchingDays.first;

      // Step 3: Check if mensa is closed
      if (todayData['closed'] == true) {
        return MensaDay(date: DateTime.now(), closed: true, meals: []);
      }

      // Step 4: Get meals for today
      final mealsResponse = await _makeRequest(
        'GET',
        '$baseUrl/canteens/$canteenId/days/$todayStr/meals',
      );

      final meals = (jsonDecode(mealsResponse) as List<dynamic>)
          .map((m) => Meal.fromJson(m as Map<String, dynamic>))
          .where((m) => m.isValid())
          .toList();

      return MensaDay(date: DateTime.now(), closed: false, meals: meals);
    } catch (e) {
      _logError('getMealsForToday', e);
      rethrow;
    }
  }

  /// Make HTTP request with timeout and retry logic
  /// Retries once on timeout, network error, or 5xx
  /// No retry on 4xx errors
  Future<String> _makeRequest(String method, String url) async {
    int attemptCount = 0;
    const maxAttempts = 2; // 1 initial + 1 retry

    while (attemptCount < maxAttempts) {
      attemptCount++;
      try {
        final response = await _httpClient
            .get(Uri.parse(url))
            .timeout(requestTimeout)
            .catchError((e) => throw NetworkException('Network error: $e'));

        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          // 4xx: Don't retry
          throw HttpException(
            'HTTP ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } else if (response.statusCode >= 500) {
          // 5xx: Retry once
          if (attemptCount < maxAttempts) {
            _logError(method, 'HTTP ${response.statusCode}, retrying...');
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          throw HttpException(
            'HTTP ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      } on TimeoutException {
        if (attemptCount < maxAttempts) {
          _logError(method, 'Timeout, retrying...');
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        throw TimeoutException('Request timeout after $maxAttempts attempts');
      }
    }

    throw Exception('Request failed after $maxAttempts attempts');
  }

  void _logError(String method, dynamic error) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] $method: $error');
  }
}

/// Exception classes
class OpenMensaException implements Exception {
  final String message;

  OpenMensaException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends OpenMensaException {
  NetworkException(String message) : super('Netzwerkfehler: $message');
}

class HttpException extends OpenMensaException {
  final int? statusCode;

  HttpException(String message, {this.statusCode})
      : super('HTTP-Fehler: $message');
}
