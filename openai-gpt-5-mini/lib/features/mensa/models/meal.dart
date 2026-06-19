import '../mappings.dart';

class Meal {
  final int id;
  final String name;
  final String category;
  final double price;
  final String? imageUrl;
  final List<String> allergens;
  final List<String> additives;

  Meal(
      {required this.id,
      required this.name,
      required this.category,
      required this.price,
      this.imageUrl,
      List<String>? allergens,
      List<String>? additives})
      : allergens = allergens ?? [],
        additives = additives ?? [];

  factory Meal.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) throw Exception('Missing id');
    final id = json['id'] as int;
    final name = (json['name'] as String?)?.trim();
    if (name == null || name.isEmpty) throw Exception('Missing name');

    final prices = json['prices'] as Map<String, dynamic>?;
    double? price;
    if (prices != null) {
      // support various key names (English and German)
      final candidates = [
        'students',
        'students_price',
        'employees',
        'pupils',
        'others',
        'Studierende',
        'Bedienstete',
      ];
      for (final k in candidates) {
        if (prices.containsKey(k)) {
          final val = prices[k];
          if (val != null) {
            price =
                (val is num) ? val.toDouble() : double.tryParse(val.toString());
            break;
          }
        }
      }
      // fallback: take first numeric value in prices map
      if (price == null) {
        for (final v in prices.values) {
          if (v is num) {
            price = v.toDouble();
            break;
          }
          final parsed = double.tryParse(v?.toString() ?? '');
          if (parsed != null) {
            price = parsed;
            break;
          }
        }
      }
    }
    if (price == null) throw Exception('Missing price');

    final rawCategory = json['category'] as String? ?? 'Sonstiges';
    final category = mapCategory(rawCategory);

    final image = json['image'] as String?;

    // OpenMensa sometimes provides allergens inside `notes` (German labels).
    final rawAllergens = <String>[];
    if (json['allergens'] != null) {
      rawAllergens.addAll(
          (json['allergens'] as List<dynamic>).map((e) => e?.toString() ?? ''));
    }
    if (json['notes'] != null) {
      rawAllergens.addAll(
          (json['notes'] as List<dynamic>).map((e) => e?.toString() ?? ''));
    }
    // map and deduplicate
    final allergens = rawAllergens
        .map((a) => mapAllergen(a))
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final additives = (json['additives'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // normalize image URL: prefix protocol if needed
    String? imageUrlFinal;
    if (image != null && image.isNotEmpty) {
      if (image.startsWith('//'))
        imageUrlFinal = 'https:' + image;
      else if (image.startsWith('/'))
        imageUrlFinal = 'https://api.studentenwerk-dresden.de' + image;
      else
        imageUrlFinal = image;
    }

    return Meal(
        id: id,
        name: name,
        category: category,
        price: price,
        imageUrl: imageUrlFinal,
        allergens: allergens,
        additives: additives);
  }
}
