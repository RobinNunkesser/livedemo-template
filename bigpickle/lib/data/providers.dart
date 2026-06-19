import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'mensa_client.dart';
import 'mensa_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final mensaClientProvider = Provider<MensaClient>((ref) {
  final client = ref.watch(httpClientProvider);
  return MensaClient(client: client);
});

final mensaRepositoryProvider = Provider<MensaRepository>((ref) {
  final client = ref.watch(mensaClientProvider);
  return MensaRepository(client);
});
