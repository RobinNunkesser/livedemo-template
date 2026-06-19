/// Port (Interface) für den Mensa-Datenzugriff.
///
/// Definiert in der Application-Schicht genutzte Abstraktion; konkrete
/// Adapter (HTTP) liegen in der Data-Schicht (C4-Sicht, Schichtregel
/// UI -> Application -> Data).
library;

import '../domain/mensa_day.dart';

/// Fehlerarten beim Mensa-Datenzugriff (für nutzerfreundliche Meldungen).
enum MensaErrorKind { timeout, network, http, parse, unknown }

class MensaRepositoryException implements Exception {
  MensaRepositoryException(this.kind, this.message, {this.statusCode});

  final MensaErrorKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'MensaRepositoryException($kind, $statusCode): $message';
}

/// Port: Liefert den Mensa-Tag für ein gegebenes Datum.
abstract interface class MensaRepository {
  /// Lädt den Mensa-Tag (Status + Gerichte) für [date] (yyyy-MM-dd).
  ///
  /// Wirft [MensaRepositoryException] bei Fehlern.
  Future<MensaDay> getDay(String date);
}
