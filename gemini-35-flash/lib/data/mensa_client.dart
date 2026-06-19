import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MensaClient {
  final http.Client _client;
  final String baseUrl;

  MensaClient({
    http.Client? client,
    this.baseUrl = 'https://api.studentenwerk-dresden.de/openmensa/v2',
  }) : _client = client ?? http.Client();

  void _logError({
    required String endpoint,
    int? statusCode,
    required String errorClass,
    required String message,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    // Output error log to standard console in structured format
    print('[$timestamp] ERROR - Endpoint: $endpoint, Status: ${statusCode ?? "N/A"}, Class: $errorClass, Msg: $message');
  }

  Future<http.Response> _getWithRetry(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    Future<http.Response> attempt() async {
      return await _client.get(url).timeout(const Duration(seconds: 5));
    }

    try {
      final response = await attempt();
      if (response.statusCode >= 500) {
        throw http.ClientException('Server error: ${response.statusCode}', url);
      }
      return response;
    } catch (e) {
      // Determine if we should retry (only for TimeoutException, ClientException/SocketException, or thrown 5xx ClientException)
      final isTimeout = e is TimeoutException;
      final isNetworkOrServer = e is http.ClientException;
      final isGeneralException = e is Exception;

      if (isTimeout || isNetworkOrServer || isGeneralException) {
        // Log the first attempt failure
        _logError(
          endpoint: endpoint,
          errorClass: isTimeout ? 'timeout' : 'network',
          message: 'First attempt failed: $e. Retrying once...',
        );

        // Perform the single retry
        try {
          final retryResponse = await attempt();
          if (retryResponse.statusCode >= 500) {
            _logError(
              endpoint: endpoint,
              statusCode: retryResponse.statusCode,
              errorClass: 'http',
              message: 'Retry failed with server error: ${retryResponse.statusCode}',
            );
            throw http.ClientException('Server error on retry: ${retryResponse.statusCode}', url);
          }
          return retryResponse;
        } catch (retryErr) {
          _logError(
            endpoint: endpoint,
            errorClass: retryErr is TimeoutException ? 'timeout' : 'network',
            message: 'Retry attempt failed: $retryErr',
          );
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<List<dynamic>> getDays(int canteenId) async {
    final endpoint = '/canteens/$canteenId/days';
    try {
      final response = await _getWithRetry(endpoint);
      if (response.statusCode != 200) {
        _logError(
          endpoint: endpoint,
          statusCode: response.statusCode,
          errorClass: 'http',
          message: 'Failed to load days: status ${response.statusCode}',
        );
        throw http.ClientException('Failed to load days: status ${response.statusCode}');
      }
      return json.decode(response.body) as List<dynamic>;
    } catch (e) {
      if (e is FormatException) {
        _logError(
          endpoint: endpoint,
          errorClass: 'parse',
          message: 'Failed to parse JSON response: $e',
        );
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getMeals(int canteenId, String dateStr) async {
    final endpoint = '/canteens/$canteenId/days/$dateStr/meals';
    try {
      final response = await _getWithRetry(endpoint);
      if (response.statusCode != 200) {
        _logError(
          endpoint: endpoint,
          statusCode: response.statusCode,
          errorClass: 'http',
          message: 'Failed to load meals for $dateStr: status ${response.statusCode}',
        );
        throw http.ClientException('Failed to load meals for $dateStr: status ${response.statusCode}');
      }
      return json.decode(response.body) as List<dynamic>;
    } catch (e) {
      if (e is FormatException) {
        _logError(
          endpoint: endpoint,
          errorClass: 'parse',
          message: 'Failed to parse JSON response: $e',
        );
      }
      rethrow;
    }
  }
}
