import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mensa_repository.dart';

final mensaRepositoryProvider = Provider<MensaRepository>((ref) {
  return MensaRepository();
});
