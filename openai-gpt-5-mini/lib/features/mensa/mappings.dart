Map<String, String> allergenCodeToGerman = {
  // common English codes / labels -> German labels
  'gluten': 'Glutenhaltiges Getreide',
  'crustaceans': 'Krebstiere',
  'eggs': 'Eier',
  'fish': 'Fisch',
  'peanuts': 'Erdnuesse',
  'soy': 'Soja',
  'milk': 'Milch/Laktose',
  'nuts': 'Schalenfruechte',
  'celery': 'Sellerie',
  'mustard': 'Senf',
  'sesame': 'Sesam',
  'sulphur': 'Schwefeldioxid/Sulfit',
  'sulphur dioxide': 'Schwefeldioxid/Sulfit',
  'lupin': 'Lupinen',
  'molluscs': 'Weichtiere',
  // German labels pass-through (common forms)
  'glutenhaltiges getreide': 'Glutenhaltiges Getreide',
  'krebstiere': 'Krebstiere',
  'eier': 'Eier',
  'fisch': 'Fisch',
  'erdnuesse': 'Erdnuesse',
  'soja': 'Soja',
  'milch/laktose': 'Milch/Laktose',
  'schalenfruechte': 'Schalenfruechte',
  'sellerie': 'Sellerie',
  'senf': 'Senf',
  'sesam': 'Sesam',
  'schwefeldioxid/sulfit': 'Schwefeldioxid/Sulfit',
  'lupinen': 'Lupinen',
  'weichtiere': 'Weichtiere',
};

String mapAllergen(String raw) {
  if (raw == null) return raw;
  final key = raw.toLowerCase().trim();
  return allergenCodeToGerman[key] ??
      // fallback: capitalize first letter and use as-is
      (raw.isNotEmpty ? (raw[0].toUpperCase() + raw.substring(1)) : raw);
}

Map<String, String> categoryMapping = {
  'meat': 'Fleisch',
  'fish': 'Fisch',
  'vegetarian': 'Vegetarisch',
  'vegan': 'Vegan',
  'side dish': 'Beilagen',
  'side': 'Beilagen',
  'soup': 'Suppen',
  'dessert': 'Desserts',
  'drinks': 'Getränke',
};

String mapCategory(String raw) {
  if (raw == null) return 'Sonstiges';
  final key = raw.toLowerCase().trim();
  return categoryMapping[key] ?? raw;
}
