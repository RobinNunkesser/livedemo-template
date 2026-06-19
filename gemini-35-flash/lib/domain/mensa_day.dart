class MensaDay {
  final DateTime date;
  final bool closed;

  MensaDay({
    required this.date,
    required this.closed,
  });

  factory MensaDay.fromJson(Map<String, dynamic> json) {
    final dateVal = json['date'];
    if (dateVal == null) {
      throw ArgumentError('Date must not be null');
    }
    final DateTime date = DateTime.parse(dateVal.toString());
    
    final closedVal = json['closed'];
    final bool closed = closedVal == true;

    return MensaDay(
      date: date,
      closed: closed,
    );
  }
}
