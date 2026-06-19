import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/meal.dart';
import '../domain/mensa_day.dart';
import 'mensa_repository.dart';

/// Fehlerklassen für den HTTP-Client.
enum MensaErrorKind { timeout, network, http, parse }

class MensaException implements Exception {
  const MensaException({
    required this.kind,
    required this.endpoint,
    this.statusCode,
    this.timestamp,
  });

  final MensaErrorKind kind;
  final String endpoint;
  final int? statusCode;
  final String? timestamp;

  @override
  String toString() =>
      'MensaException(kind: $kind, endpoint: $endpoint, '
      'status: $statusCode, ts: $timestamp)';
}

/// HTTP-Adapter für die OpenMensa-API des Studentenwerks Dresden.
///
/// Verbindliche Regeln laut TechDesign-Mensaplan.md:
/// - Timeout: 5 Sekunden
/// - Retry: genau 1x bei Timeout/Network/5xx
/// - Kein Retry bei 4xx
/// - Ungültige Meals werden stillschweigend verworfen
class MensaClient implements MensaRepository {
  MensaClient({http.Client? client})
      : _client = client ?? http.Client();

  static const _baseUrl =
      'https://api.studentenwerk-dresden.de/openmensa/v2';
  static const _canteenId = 6;
  static const _timeout = Duration(seconds: 5);

  final http.Client _client;

  @override
  Future<List<MensaDay>> getDays() async {
    final endpoint = '$_baseUrl/canteens/$_canteenId/days';
    final response = await _getWithRetry(endpoint);
    try {
      final list = jsonDecode(response.body) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(MensaDay.fromJson)
          .toList();
    } catch (e) {
      _log(MensaErrorKind.parse, endpoint, null, e.toString());
      throw MensaException(
        kind: MensaErrorKind.parse,
        endpoint: endpoint,
        timestamp: _now(),
      );
    }
  }

  @override
  Future<List<Meal>> getMealsForDay(String date) async {
    final endpoint = '$_baseUrl/canteens/$_canteenId/days/$date/meals';
    final response = await _getWithRetry(endpoint);
    try {
      final list = jsonDecode(response.body) as List;
      final meals = <Meal>[];
      for (final item in list.cast<Map<String, dynamic>>()) {
        final meal = Meal.fromJson(item);
        if (meal != null) {
          meals.add(meal);
        } else {
          // Ungültiger Datensatz wird stillschweigend verworfen und geloggt.
          _log(MensaErrorKind.parse, endpoint, null,
              'Invalid meal discarded: $item');
        }
      }
      return meals;
    } catch (e) {
      _log(MensaErrorKind.parse, endpoint, null, e.toString());
      throw MensaException(
        kind: MensaErrorKind.parse,
        endpoint: endpoint,
        timestamp: _now(),
      );
    }
  }

  /// GET mit genau 1 automatischem Retry bei Timeout/Network/5xx.
  Future<http.Response> _getWithRetry(String endpoint) async {
    http.Response? response;
    MensaException? lastException;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        response = await _client
            .get(Uri.parse(endpoint))
            .timeout(_timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // 4xx → kein Retry
        if (response.statusCode >= 400 && response.statusCode < 500) {
          _log(MensaErrorKind.http, endpoint, response.statusCode,
              'Client error, no retry');
          throw MensaException(
            kind: MensaErrorKind.http,
            endpoint: endpoint,
            statusCode: response.statusCode,
            timestamp: _now(),
          );
        }

        // 5xx → Retry beim ersten Versuch
        _log(MensaErrorKind.http, endpoint, response.statusCode,
            'Server error, attempt $attempt');
        lastException = MensaException(
          kind: MensaErrorKind.http,
          endpoint: endpoint,
          statusCode: response.statusCode,
          timestamp: _now(),
        );
      } on TimeoutException {
        _log(MensaErrorKind.timeout, endpoint, null, 'Timeout, attempt $attempt');
        lastException = MensaException(
          kind: MensaErrorKind.timeout,
          endpoint: endpoint,
          timestamp: _now(),
        );
      } on SocketException catch (e) {
        _log(MensaErrorKind.network, endpoint, null,
            'Network error: $e, attempt $attempt');
        lastException = MensaException(
          kind: MensaErrorKind.network,
          endpoint: endpoint,
          timestamp: _now(),
        );
      }

      // Kein zweiter Retry-Versuch nach dem zweiten Anlauf
      if (attempt >= 1) break;
    }

    throw lastException!;
  }

  void _log(
    MensaErrorKind kind,
    String endpoint,
    int? statusCode,
    String detail,
  ) {
    // Internes Logging für Debugging/Analyse (laut TechDesign-Mensaplan.md).
    // In Produktion würde hier ein richtiger Logger eingesetzt.
    // ignore: avoid_print
    print('[MensaClient] ${_now()} kind=$kind endpoint=$endpoint '
        'status=$statusCode detail=$detail');
  }

  String _now() => DateTime.now().toUtc().toIso8601String();
}
