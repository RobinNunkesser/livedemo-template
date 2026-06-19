// TODO(Sprint 4): Data model for exercise/task entries
class Exercise {
  final String id;
  final String title;
  final String? description;
  final String course;
  final DateTime deadline;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exercise({
    required this.id,
    required this.title,
    this.description,
    required this.course,
    required this.deadline,
    this.status = 'offen',
    this.priority = 'normal',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue => deadline.isBefore(DateTime.now()) && status == 'offen';

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      title: json['titel'] as String? ?? '',
      description: json['beschreibung'] as String?,
      course: json['kurs'] as String? ?? '',
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'offen',
      priority: json['prioritaet'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['erstellt'] as String),
      updatedAt: DateTime.parse(json['aktualisiert'] as String),
    );
  }
}
