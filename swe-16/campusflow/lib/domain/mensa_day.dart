import 'meal.dart';

class MensaDay {
  final String date;
  final bool closed;
  final List<Meal> meals;

  MensaDay({required this.date, required this.closed, required this.meals});

  factory MensaDay.fromJson(Map<String, dynamic> json) {
    final mealsList = json['meals'] as List<dynamic>?;
    final meals =
        mealsList
            ?.map((mealJson) => Meal.fromJson(mealJson as Map<String, dynamic>))
            .where((meal) => meal.isValid())
            .toList() ??
        [];

    return MensaDay(
      date: json['date'] as String,
      closed: json['closed'] as bool? ?? false,
      meals: meals,
    );
  }
}
