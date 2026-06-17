class TimeSlot {
  const TimeSlot({
    this.id,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    this.maxBooking = 1,
    this.bookedCount = 0,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String slotDate;
  final String startTime;
  final String endTime;
  final int maxBooking;
  final int bookedCount;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  bool get isAvailable => status == 'available' && bookedCount < maxBooking;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'slot_date': slotDate,
      'start_time': startTime,
      'end_time': endTime,
      'max_booking': maxBooking,
      'booked_count': bookedCount,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TimeSlot.fromMap(Map<String, Object?> map) {
    return TimeSlot(
      id: map['id'] as int?,
      slotDate: map['slot_date'] as String? ?? '',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      maxBooking: map['max_booking'] as int? ?? 1,
      bookedCount: map['booked_count'] as int? ?? 0,
      status: map['status'] as String? ?? 'available',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
