/// Riverpod-Provider für die Data-Schicht.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'mensa_api_client.dart';
import 'mensa_repository.dart';

/// HTTP-Client-Provider (austauschbar für Tests).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Mensa-Repository (Port), implementiert durch den HTTP-Adapter.
final mensaRepositoryProvider = Provider<MensaRepository>((ref) {
  return MensaApiClient(client: ref.watch(httpClientProvider));
});
