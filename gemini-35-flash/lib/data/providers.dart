import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mensa_client.dart';
import 'mensa_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

final mensaClientProvider = Provider<MensaClient>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return MensaClient(client: httpClient);
});

final mensaRepositoryProvider = Provider<MensaRepository>((ref) {
  final client = ref.watch(mensaClientProvider);
  return MensaRepositoryImpl(client);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});
