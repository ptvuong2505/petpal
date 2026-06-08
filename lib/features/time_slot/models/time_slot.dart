class TimeSlot {
  const TimeSlot({
    this.id,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  final int? id;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'slot_date': slotDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable ? 1 : 0,
    };
  }

  factory TimeSlot.fromMap(Map<String, Object?> map) {
    return TimeSlot(
      id: map['id'] as int?,
      slotDate: DateTime.parse(map['slot_date'] as String),
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      isAvailable: (map['is_available'] as int? ?? 0) == 1,
    );
  }
}
