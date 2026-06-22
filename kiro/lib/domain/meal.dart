/// Domain model: ein einzelnes Gericht im Mensaplan.
///
/// Nur Gerichte mit [id], [name], [category] und mindestens einem gültigen
/// Preis werden aus der API-Antwort übernommen (Validierungsregel laut
/// TechDesign-Mensaplan.md).
class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.prices,
    this.imageUrl,
    this.allergens = const [],
    this.additives = const [],
  });

  final int id;
  final String name;
  final String category;

  /// Preisübersicht (mind. ein Wert ist != null, laut Validierungsregeln).
  final MealPrices prices;

  /// Optionale Bild-URL von der API.
  final String? imageUrl;

  /// Allergen-Labels in lesbarer Form, z. B. "Glutenhaltiges Getreide".
  final List<String> allergens;

  /// Zusatzstoff-Labels, z. B. "Geschmacksverstärker".
  final List<String> additives;

  /// Zeigt den günstigsten verfügbaren Preis an (Studierendenpreis bevorzugt).
  double? get displayPrice =>
      prices.students ?? prices.employees ?? prices.pupils ?? prices.others;

  /// Validierungsregel: Meal ist nur anzeigbar wenn alle Pflichtfelder gesetzt.
  static Meal? fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as int?;
      final name = json['name'] as String?;
      final category = json['category'] as String?;

      if (id == null || name == null || name.isEmpty) return null;
      if (category == null || category.isEmpty) return null;

      final prices = MealPrices.fromJson(
        (json['prices'] as Map<String, dynamic>?) ?? {},
      );
      if (!prices.hasAnyPrice) return null;

      final notes = (json['notes'] as List?)?.cast<String>() ?? [];
      final allergens = _parseAllergens(notes);
      final additives = _parseAdditives(notes);

      final imageUrl = json['image'] as String?;

      return Meal(
        id: id,
        name: name,
        category: category,
        prices: prices,
        imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
        allergens: allergens,
        additives: additives,
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> _parseAllergens(List<String> notes) {
    final result = <String>[];
    for (final note in notes) {
      // Versuche zuerst kurze Codes (Standard OpenMensa)
      final byCode = _allergenCodeToLabel[note];
      if (byCode != null) {
        result.add(byCode);
        continue;
      }
      // Studentenwerk Dresden liefert direkte Labels, z.B. "Glutenhaltiges Getreide (A)"
      // Prüfe ob der note-Text zu einem bekannten Allergen-Label passt
      for (final label in _allergenCodeToLabel.values) {
        if (note.startsWith(label) || note.contains(label)) {
          result.add(label);
          break;
        }
      }
    }
    // Duplikate entfernen
    return result.toSet().toList();
  }

  static List<String> _parseAdditives(List<String> notes) {
    final result = <String>[];
    for (final note in notes) {
      // Kurze Codes (Standard OpenMensa)
      final byCode = _additiveCodeToLabel[note];
      if (byCode != null) {
        result.add(byCode);
        continue;
      }
      // Studentenwerk Dresden: z.B. "mit Farbstoff (1)"
      for (final entry in _additiveCodeToLabel.entries) {
        if (note.contains(entry.value) ||
            note.contains('Farbstoff') && entry.key == '1' ||
            note.contains('Konservierungsstoff') && entry.key == '2' ||
            note.contains('Antioxydationsmittel') && entry.key == '3' ||
            note.contains('Antioxidationsmittel') && entry.key == '3' ||
            note.contains('Geschmacksverstärker') && entry.key == '5') {
          result.add(entry.value);
          break;
        }
      }
    }
    return result.toSet().toList();
  }

  // Mapping der 14 EU-Hauptallergene (EU-VO 1169/2011)
  // Unterstützt Kurzcode (Standard OpenMensa) und deutsche Labels (Studentenwerk Dresden)
  static const _allergenCodeToLabel = <String, String>{
    'Gl': 'Glutenhaltiges Getreide',
    'Kr': 'Krebstiere',
    'Ei': 'Eier',
    'Fi': 'Fisch',
    'Er': 'Erdnüsse',
    'So': 'Soja',
    'Mi': 'Milch/Laktose',
    'Sc': 'Schalenfrüchte (Nüsse)',
    'Se': 'Sellerie',
    'Sf': 'Senf',
    'Sa': 'Sesam',
    'Su': 'Schwefeldioxid/Sulfit',
    'Lu': 'Lupinen',
    'We': 'Weichtiere',
  };

  // Häufige Zusatzstoffe
  static const _additiveCodeToLabel = <String, String>{
    '1': 'Künstliche Farbstoffe',
    '2': 'Konservierungsstoffe',
    '3': 'Antioxidationsmittel',
    '5': 'Geschmacksverstärker',
  };

  /// Alle bekannten Allergen-Labels für die Filter-UI.
  static List<String> get allAllergenLabels =>
      _allergenCodeToLabel.values.toList();

  /// Alle bekannten Zusatzstoff-Labels für die Filter-UI.
  static List<String> get allAdditiveLabels =>
      _additiveCodeToLabel.values.toList();
}

class MealPrices {
  const MealPrices({
    this.students,
    this.employees,
    this.pupils,
    this.others,
  });

  final double? students;
  final double? employees;
  final double? pupils;
  final double? others;

  bool get hasAnyPrice =>
      students != null || employees != null || pupils != null || others != null;

  factory MealPrices.fromJson(Map<String, dynamic> json) {
    return MealPrices(
      // Unterstützt sowohl englische OpenMensa-Keys als auch
      // deutsche Keys des Studentenwerks Dresden
      students: _parseDouble(json['students'] ?? json['Studierende']),
      employees: _parseDouble(json['employees'] ?? json['Bedienstete']),
      pupils: _parseDouble(json['pupils'] ?? json['Schüler']),
      others: _parseDouble(json['others'] ?? json['Gäste']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
