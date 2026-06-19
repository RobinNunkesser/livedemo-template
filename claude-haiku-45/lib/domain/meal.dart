/// Domain model for Meal
class Meal {
  final int id;
  final String name;
  final String category;
  final Map<String, double?> prices; // {students, employees, pupils, others}
  final String? imageUrl;
  final List<String> allergens;
  final List<String> additives;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.prices,
    this.imageUrl,
    this.allergens = const [],
    this.additives = const [],
  });

  /// Validate if meal has required fields for display
  bool isValid() {
    return id > 0 &&
        name.isNotEmpty &&
        category.isNotEmpty &&
        prices.values.any((price) => price != null && price > 0);
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final pricesJson = json['prices'] as Map<String, dynamic>? ?? {};
    return Meal(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      prices: {
        'students':
            ((pricesJson['Studierende'] ?? pricesJson['students']) as num?)
                ?.toDouble(),
        'employees':
            ((pricesJson['Bedienstete'] ?? pricesJson['employees']) as num?)
                ?.toDouble(),
        'pupils': (pricesJson['pupils'] as num?)?.toDouble(),
        'others': (pricesJson['others'] as num?)?.toDouble(),
      },
      imageUrl: json['image'] as String?,
      allergens: List<String>.from(json['allergens'] ?? []),
      additives: List<String>.from(json['additives'] ?? []),
    );
  }
}
