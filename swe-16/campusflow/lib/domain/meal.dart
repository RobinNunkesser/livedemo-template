class Meal {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? image;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.image,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final prices = json['prices'] as Map<String, dynamic>?;
    final studentPrice = prices?['students'] as num?;

    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: studentPrice?.toDouble() ?? 0.0,
      image: json['image'] as String?,
    );
  }

  bool isValid() {
    return id.isNotEmpty && name.isNotEmpty && category.isNotEmpty && price > 0;
  }
}
