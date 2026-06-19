import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/mensa_day.dart';
import 'mensa_repository.dart';
import 'mensa_client.dart';

/// Provider for Mensa HTTP client (Singleton)
final mensaClientProvider = Provider<OpenMensaClient>((ref) {
  return OpenMensaClient();
});

/// Provider for Mensa Repository
final mensaRepositoryProvider = Provider<IMensaRepository>((ref) {
  final client = ref.watch(mensaClientProvider);
  return MensaRepositoryImpl(client);
});

/// Concrete implementation of IMensaRepository
class MensaRepositoryImpl implements IMensaRepository {
  final OpenMensaClient _client;

  MensaRepositoryImpl(this._client);

  @override
  Future<MensaDay?> getMealsForToday() async {
    return await _client.getMealsForToday();
  }
}
