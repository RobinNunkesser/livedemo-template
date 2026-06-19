// TODO(Sprint 3): Data model for lecturer entries
class Lecturer {
  final String id;
  final String name;
  final String title;
  final String? degree;
  final String department;
  final String email;
  final String? phone;
  final String? office;
  final String? officeHours;
  final List<String> courses;
  final List<String> fields;

  const Lecturer({
    required this.id,
    required this.name,
    required this.title,
    this.degree,
    required this.department,
    required this.email,
    this.phone,
    this.office,
    this.officeHours,
    this.courses = const [],
    this.fields = const [],
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['titel'] as String? ?? '',
      degree: json['grad'] as String?,
      department: json['fachbereich'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['telefon'] as String?,
      office: json['buero'] as String?,
      officeHours: json['sprechstunden'] as String?,
      courses: (json['kurse'] as List<dynamic>?)?.cast<String>() ?? [],
      fields: (json['fachgebiete'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
