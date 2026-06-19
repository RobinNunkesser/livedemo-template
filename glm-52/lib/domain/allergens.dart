/// Allergen- und Zusatzstoff-Mapping für die OpenMensa-API
/// des Studentenwerks Dresden.
///
/// Die API liefert Allergene als Text in Klammern, z. B.
/// "Glutenhaltiges Getreide (A)" oder "Sellerie (I)".
/// Hier wird der Code (A–N) auf einen lesbaren Namen gemappt (A4/A5).
///
/// Zusatzstoffe erscheinen als numerische Codes, z. B. "mit Farbstoff (1)".
library;

/// Ein Allergen oder eine Zusatzstoff-Kategorie mit Code und Klartext.
class Allergen {
  const Allergen(
      {required this.code, required this.name, this.isAdditive = false});

  /// Code aus der API, z. B. "A" oder "1".
  final String code;

  /// Menschlich lesbarer Name, z. B. "Glutenhaltiges Getreide".
  final String name;

  /// true für Zusatzstoffe (Filter separat zu Allergenen möglich).
  final bool isAdditive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Allergen && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Allergen($code: $name)';
}

/// Die 14 EU-Hauptallergene (EU-VO 1169/2011) als Codes A–N,
/// ergänzt um die vom Studentenwerk Dresden verwendeten Subcodes.
class AllergenCatalog {
  AllergenCatalog._();

  /// 14 EU-Hauptallergene, sortiert nach API-Code des Studentenwerks.
  static const List<Allergen> mainAllergens = [
    Allergen(code: 'A', name: 'Glutenhaltiges Getreide'),
    Allergen(code: 'B', name: 'Krebstiere'),
    Allergen(code: 'C', name: 'Eier'),
    Allergen(code: 'D', name: 'Fisch'),
    Allergen(code: 'E', name: 'Erdnüsse'),
    Allergen(code: 'F', name: 'Soja'),
    Allergen(code: 'G', name: 'Milch / Milchzucker (Laktose)'),
    Allergen(code: 'H', name: 'Schalenfrüchte (Nüsse)'),
    Allergen(code: 'I', name: 'Sellerie'),
    Allergen(code: 'J', name: 'Senf'),
    Allergen(code: 'K', name: 'Sesam'),
    Allergen(code: 'L', name: 'Schwefeldioxid / Sulfit'),
    Allergen(code: 'M', name: 'Lupinen'),
    Allergen(code: 'N', name: 'Weichtiere'),
  ];

  /// Häufige Zusatzstoffe als numerische Codes.
  static const List<Allergen> additives = [
    Allergen(code: '1', name: 'Künstliche Farbstoffe', isAdditive: true),
    Allergen(code: '2', name: 'Konservierungsstoffe', isAdditive: true),
    Allergen(code: '3', name: 'Antioxidationsmittel', isAdditive: true),
    Allergen(code: '9', name: 'Geschmacksverstärker', isAdditive: true),
  ];

  /// Map Code -> Allergen für schnelle Lookups beim Parsen.
  static final Map<String, Allergen> _byCode = {
    for (final a in [...mainAllergens, ...additives]) a.code: a,
  };

  /// Liefert das Allergen für einen Code, oder null wenn unbekannt
  /// (unbekannte Codes werden ignoriert – Tech-Design Mensaplan).
  static Allergen? byCode(String code) => _byCode[code];

  /// Alle filterbaren Einträge (Allergene + Zusatzstoffe).
  static List<Allergen> get all => [...mainAllergens, ...additives];
}
