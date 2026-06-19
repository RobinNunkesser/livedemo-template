/// Domain model: ein Tag im Mensaplan.
class MensaDay {
  const MensaDay({required this.date, required this.closed});

  final String date; // ISO-8601: yyyy-MM-dd
  final bool closed;

  factory MensaDay.fromJson(Map<String, dynamic> json) {
    return MensaDay(
      date: json['date'] as String? ?? '',
      closed: json['closed'] as bool? ?? false,
    );
  }
}
