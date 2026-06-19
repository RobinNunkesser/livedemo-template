/// Domain-Modell für ein Mensa-Gericht.
///
/// Entspricht den Pflichtfeldern aus Tech-Design Mensaplan:
/// id, name, category, price. Bild und Allergene sind optional.
library;

import 'allergens.dart';

/// Speisekategorie, die für den Kategorie-Filter (A16) genutzt wird.
///
/// Die OpenMensa-API des Studentenwerks Dresden liefert Freitext-Kategorien
/// wie "Angebot 1" oder "Suppe". Für den Filter "Fleisch / Fisch /
/// Vegetarisch / Vegan" (A16) leiten wir die Speise-Kategorie daher aus den
/// `notes` ab (z. B. "Menü ist vegan").
enum FoodCategory {
  fleisch,
  fisch,
  vegetarisch,
  vegan,
  sonstiges;

  /// Menschlich lesbares Label für UI und Filter.
  String get label {
    switch (this) {
      case FoodCategory.fleisch:
        return 'Fleisch';
      case FoodCategory.fisch:
        return 'Fisch';
      case FoodCategory.vegetarisch:
        return 'Vegetarisch';
      case FoodCategory.vegan:
        return 'Vegan';
      case FoodCategory.sonstiges:
        return 'Sonstiges';
    }
  }
}

class Meal {
  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.priceStudent,
    this.priceEmployee,
    this.imageUrl,
    this.allergens = const [],
    this.foodCategory = FoodCategory.sonstiges,
    this.soldOut = false,
  });

  /// Eindeutige Gericht-ID (Pflichtfeld).
  final int id;

  /// Gerichtname (Pflichtfeld, nicht leer).
  final String name;

  /// Original-Kategorie aus der API (z. B. "Angebot 1", "Suppe").
  final String category;

  /// Preis für Studierende (Pflichtfeld für Anzeige).
  final double? priceStudent;

  /// Preis für Beschäftigte (optional).
  final double? priceEmployee;

  /// Bild-URL (optional). Platzhalter, falls null/ungültig.
  final String? imageUrl;

  /// Aufgeschlüsselte Allergene/Zusatzstoffe als lesbare Codes.
  final List<Allergen> allergens;

  /// Für den Kategorie-Filter abgeleitete Speise-Kategorie.
  final FoodCategory foodCategory;

  /// Gericht ausverkauft?
  final bool soldOut;

  /// Erster verfügbarer Preis (Studierende bevorzugt).
  double? get price => priceStudent ?? priceEmployee;

  /// Formatierter Preis für die Anzeige, z. B. "€3,50".
  String get priceDisplay {
    final p = price;
    if (p == null) return '';
    return '€${p.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Ob das Gericht eines der gewählten Allergene enthält (für Filter).
  bool containsAnyAllergen(Set<String> allergenCodes) {
    if (allergenCodes.isEmpty) return false;
    return allergens.any((a) => allergenCodes.contains(a.code));
  }

  @override
  String toString() => 'Meal($id, $name, $foodCategory, $priceDisplay)';
}
