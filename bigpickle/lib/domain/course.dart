// TODO(Sprint 2): Data model for course/schedule entries
class Course {
  final String id;
  final String name;
  final String weekday;
  final String time;
  final String room;
  final String lecturer;
  final String rhythm;
  final String? weeks;

  const Course({
    required this.id,
    required this.name,
    required this.weekday,
    required this.time,
    required this.room,
    required this.lecturer,
    this.rhythm = 'wöchentlich',
    this.weeks,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      name: json['kurs'] as String? ?? '',
      weekday: json['wochentag'] as String? ?? '',
      time: json['zeit'] as String? ?? '',
      room: json['raum'] as String? ?? '',
      lecturer: json['dozent'] as String? ?? '',
      rhythm: json['rhythmus'] as String? ?? 'wöchentlich',
      weeks: json['wochen'] as String?,
    );
  }
}
