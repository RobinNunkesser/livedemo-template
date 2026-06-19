import '../domain/meal.dart';
import '../domain/mensa_day.dart';

/// Repository-Interface (Port) für Mensadaten.
/// Konkrete Implementierungen in [MensaClient].
abstract interface class MensaRepository {
  /// Lädt alle verfügbaren Tage für die Kantine.
  Future<List<MensaDay>> getDays();

  /// Lädt die Gerichte für einen bestimmten Tag (ISO-8601: yyyy-MM-dd).
  Future<List<Meal>> getMealsForDay(String date);
}
