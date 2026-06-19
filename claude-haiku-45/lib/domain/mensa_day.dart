import 'package:intl/intl.dart';
import 'meal.dart';

/// Domain model for MensaDay with meals
class MensaDay {
  final DateTime date;
  final bool closed;
  final List<Meal> meals;

  MensaDay({required this.date, required this.closed, required this.meals});

  factory MensaDay.fromJson(Map<String, dynamic> json) {
    return MensaDay(
      date: DateFormat('yyyy-MM-dd').parse(json['date'] as String? ?? ''),
      closed: json['closed'] as bool? ?? false,
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map((m) => Meal.fromJson(m as Map<String, dynamic>))
              .where((m) => m.isValid())
              .toList() ??
          [],
    );
  }

  String get formattedDate => DateFormat.yMMMd('de_DE').format(date);
  bool get isToday => DateUtils.isSameDay(date, DateTime.now());
}

/// Helper for date comparison
class DateUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
