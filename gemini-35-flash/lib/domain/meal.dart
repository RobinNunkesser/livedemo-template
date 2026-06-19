const Map<String, String> allergenNames = {
  'A': 'Glutenhaltiges Getreide',
  'B': 'Krebstiere',
  'C': 'Eier',
  'D': 'Fisch',
  'E': 'Erdnüsse',
  'F': 'Soja',
  'G': 'Milch/Laktose',
  'H': 'Schalenfrüchte (Nüsse)',
  'I': 'Sellerie',
  'J': 'Senf',
  'K': 'Sesam',
  'L': 'Schwefeldioxid/Sulfit',
  'M': 'Lupinen',
  'N': 'Weichtiere',
};

const Map<String, String> additiveNames = {
  '1': 'Künstliche Farbstoffe',
  '2': 'Konservierungsstoffe',
  '3': 'Antioxidationsmittel',
  '4': 'Geschmacksverstärker',
};

class Meal {
  final int id;
  final String name;
  final String category;
  final double studentPrice;
  final double employeePrice;
  final String? imageUrl;
  final List<String> allergens;
  final List<String> additives;
  final String dietaryType; // 'Fleisch', 'Vegetarisch', 'Vegan'

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.studentPrice,
    required this.employeePrice,
    this.imageUrl,
    required this.allergens,
    required this.additives,
    required this.dietaryType,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    if (idVal == null) {
      throw ArgumentError('ID must not be null');
    }
    final int id = idVal is int ? idVal : int.parse(idVal.toString());

    final nameVal = json['name'];
    if (nameVal == null || nameVal.toString().trim().isEmpty) {
      throw ArgumentError('Name must not be empty');
    }
    final String name = nameVal.toString();

    final categoryVal = json['category'];
    if (categoryVal == null || categoryVal.toString().trim().isEmpty) {
      throw ArgumentError('Category must not be empty');
    }
    final String category = categoryVal.toString();

    // Flexible price extraction to handle German/English keys
    double studentPrice = 0.0;
    double employeePrice = 0.0;

    final pricesVal = json['prices'];
    if (pricesVal is Map<String, dynamic>) {
      // German keys from Studentenwerk Dresden API
      final studPriceGerman = pricesVal['Studierende'];
      final bedPriceGerman = pricesVal['Bedienstete'];
      // English keys from standard OpenMensa API / Tech Design
      final studPriceEnglish = pricesVal['students'];
      final bedPriceEnglish = pricesVal['employees'];

      final stPrice = studPriceGerman ?? studPriceEnglish;
      final emPrice = bedPriceGerman ?? bedPriceEnglish;

      if (stPrice != null) {
        studentPrice = double.tryParse(stPrice.toString()) ?? 0.0;
      }
      if (emPrice != null) {
        employeePrice = double.tryParse(emPrice.toString()) ?? 0.0;
      }
    }

    if (studentPrice <= 0.0 && employeePrice <= 0.0) {
      throw ArgumentError('At least one price (student or employee) must be present and valid');
    }

    String? imageUrl;
    final imageVal = json['image'];
    if (imageVal != null && imageVal.toString().trim().isNotEmpty) {
      var img = imageVal.toString().trim();
      // Prefix with https: if it's double-slash relative
      if (img.startsWith('//')) {
        img = 'https:$img';
      }
      imageUrl = img;
    }

    // Extract notes
    final List<String> notes = [];
    final notesVal = json['notes'];
    if (notesVal is List) {
      notes.addAll(notesVal.map((e) => e.toString()));
    }

    // Parse allergens & additives
    final allergensSet = <String>{};
    final additivesSet = <String>{};
    final regex = RegExp(r'\(([A-Z0-9]+)\)');

    for (final note in notes) {
      for (final match in regex.allMatches(note)) {
        final code = match.group(1);
        if (code != null && code.isNotEmpty) {
          final firstChar = code[0].toUpperCase();
          if (allergenNames.containsKey(firstChar)) {
            allergensSet.add(allergenNames[firstChar]!);
          } else if (additiveNames.containsKey(code)) {
            additivesSet.add(additiveNames[code]!);
          }
        }
      }
    }

    // Determine dietary type
    String dietaryType = 'Fleisch';
    final notesLower = notes.map((n) => n.toLowerCase()).toList();
    if (notesLower.any((n) => n.contains('vegan'))) {
      dietaryType = 'Vegan';
    } else if (notesLower.any((n) => n.contains('vegetarisch'))) {
      dietaryType = 'Vegetarisch';
    }

    return Meal(
      id: id,
      name: name,
      category: category,
      studentPrice: studentPrice,
      employeePrice: employeePrice,
      imageUrl: imageUrl,
      allergens: allergensSet.toList()..sort(),
      additives: additivesSet.toList()..sort(),
      dietaryType: dietaryType,
    );
  }
}
