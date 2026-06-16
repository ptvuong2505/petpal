class StaffSlotAssignment {
  const StaffSlotAssignment({
    this.id,
    required this.staffId,
    required this.timeSlotId,
    this.bookingId,
    required this.assignmentDate,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int staffId;
  final int timeSlotId;
  final int? bookingId;
  final String assignmentDate; // Format: YYYY-MM-DD
  final String status; // 'available', 'booked', 'unavailable'
  final String? createdAt;
  final String? updatedAt;

  bool get isAvailable => status == 'available' && bookingId == null;
  bool get isBooked => status == 'booked' || bookingId != null;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'time_slot_id': timeSlotId,
      'booking_id': bookingId,
      'assignment_date': assignmentDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory StaffSlotAssignment.fromMap(Map<String, Object?> map) {
    return StaffSlotAssignment(
      id: map['id'] as int?,
      staffId: map['staff_id'] as int? ?? 0,
      timeSlotId: map['time_slot_id'] as int? ?? 0,
      bookingId: map['booking_id'] as int?,
      assignmentDate: map['assignment_date'] as String? ?? '',
      status: map['status'] as String? ?? 'available',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  StaffSlotAssignment copyWith({
    int? id,
    int? staffId,
    int? timeSlotId,
    int? bookingId,
    String? assignmentDate,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return StaffSlotAssignment(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      bookingId: bookingId ?? this.bookingId,
      assignmentDate: assignmentDate ?? this.assignmentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
