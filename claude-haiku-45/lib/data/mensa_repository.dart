import '../domain/mensa_day.dart';

/// Repository interface for Mensa data
abstract class IMensaRepository {
  /// Get meals for today
  /// Throws exceptions on network/API errors
  Future<MensaDay?> getMealsForToday();
}
