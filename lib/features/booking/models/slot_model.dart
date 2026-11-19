class SlotModel {
  final String time; // "09:00" (business time)
  final DateTime startAtUtc;
  final DateTime endAtUtc;
  final bool available;

  /// Why it is not available: 'past', 'busy' (admin blocked it) or 'booked'.
  final String? reason;

  const SlotModel({
    required this.time,
    required this.startAtUtc,
    required this.endAtUtc,
    required this.available,
    this.reason,
  });

  factory SlotModel.fromJson(Map<String, dynamic> j) => SlotModel(
        time: (j['time'] ?? '').toString(),
        startAtUtc: DateTime.parse(j['startAt'].toString()).toUtc(),
        endAtUtc: DateTime.parse(j['endAt'].toString()).toUtc(),
        available: j['available'] == true,
        reason: j['reason']?.toString(),
      );

  DateTime get startLocal => startAtUtc.toLocal();
}
