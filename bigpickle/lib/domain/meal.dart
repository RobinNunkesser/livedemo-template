class Meal {
  final int id;
  final String name;
  final String category;
  final String? image;
  final double priceStudents;
  final double priceEmployees;
  final double pricePupils;
  final double priceOthers;
  final List<String> allergens;
  final List<String> additives;

  const Meal({
    required this.id,
    required this.name,
    required this.category,
    this.image,
    required this.priceStudents,
    required this.priceEmployees,
    required this.pricePupils,
    required this.priceOthers,
    this.allergens = const [],
    this.additives = const [],
  });

  double get bestPrice {
    if (priceStudents > 0) return priceStudents;
    if (priceEmployees > 0) return priceEmployees;
    if (pricePupils > 0) return pricePupils;
    return priceOthers;
  }

  bool get hasImage => image != null && image!.isNotEmpty;

  static const _knownAllergens = {
    'A': 'Glutenhaltiges Getreide',
    'C': 'Eier',
    'F': 'Soja',
    'G': 'Milch/Laktose',
    'I': 'Sellerie',
    'J': 'Senf',
  };

  static const _knownAdditives = {
    '1': 'mit Farbstoff',
    '3': 'mit Antioxidationsmittel',
    '9': 'mit Süßungsmittel',
  };

  static String? resolveAllergen(String code) => _knownAllergens[code];

  static String? resolveAdditive(String code) => _knownAdditives[code];

  List<String> get knownAllergens =>
      allergens.map((e) => resolveAllergen(e)).whereType<String>().toList();

  List<String> get knownAdditives =>
      additives.map((e) => resolveAdditive(e)).whereType<String>().toList();

  bool hasAnyAllergen(Set<String> allergenCodes) =>
      allergens.any((a) => allergenCodes.contains(a));

  bool hasAnyAdditive(Set<String> additiveCodes) =>
      additives.any((a) => additiveCodes.contains(a));

  static final _allergenPattern = RegExp(r'\(([ACFGIJ])\)');
  static final _additivePattern = RegExp(r'\(([139])\)');

  factory Meal.fromJson(Map<String, dynamic> json) {
    final prices = json['prices'] as Map<String, dynamic>? ?? {};
    final notes = (json['notes'] as List<dynamic>?)?.cast<String>() ?? [];

    final allergens = <String>{};
    final additives = <String>{};
    for (final note in notes) {
      for (final m in _allergenPattern.allMatches(note)) {
        final code = m.group(1)!;
        if (_knownAllergens.containsKey(code)) {
          allergens.add(code);
        }
      }
      for (final m in _additivePattern.allMatches(note)) {
        final code = m.group(1)!;
        if (_knownAdditives.containsKey(code)) {
          additives.add(code);
        }
      }
    }

    var image = json['image'] as String?;
    if (image != null && image.startsWith('//')) {
      image = 'https:$image';
    }

    return Meal(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: image,
      priceStudents: _parsePrice(prices['Studierende']),
      priceEmployees: _parsePrice(prices['Bedienstete']),
      pricePupils: _parsePrice(prices['Studierende']),
      priceOthers: _parsePrice(prices['Bedienstete']),
      allergens: allergens.toList(),
      additives: additives.toList(),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
