import 'meal.dart';

class MensaDay {
  final DateTime date;
  final bool closed;
  final List<Meal> meals;

  const MensaDay({
    required this.date,
    this.closed = false,
    this.meals = const [],
  });

  factory MensaDay.fromJson(Map<String, dynamic> json) {
    return MensaDay(
      date: DateTime.parse(json['date'] as String),
      closed: json['closed'] as bool? ?? false,
    );
  }
}
