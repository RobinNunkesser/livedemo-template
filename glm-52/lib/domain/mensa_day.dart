/// Domain-Modell für einen Mensa-Tag mit Öffnungsstatus und Gerichten.
library;

import 'meal.dart';

/// Status eines Mensa-Tages.
enum DayStatus { open, closed, noData }

class MensaDay {
  MensaDay({required this.date, required this.status, this.meals = const []});

  /// Datum im Format yyyy-MM-dd.
  final String date;

  /// Öffnungsstatus laut /days-Endpoint.
  final DayStatus status;

  /// Gerichte des Tages (leer bei geschlossen/kein Angebot).
  final List<Meal> meals;

  /// Convenience: Mensa hat heute auf und es gibt Gerichte.
  bool get hasMeals => status == DayStatus.open && meals.isNotEmpty;
}
