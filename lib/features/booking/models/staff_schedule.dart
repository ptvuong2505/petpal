class StaffSchedule {
  const StaffSchedule({
    this.id,
    required this.staffId,
    this.workStartTime = '08:30',
    this.workEndTime = '21:00',
    this.offDays,
    this.maxDailyAppointments = 10,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int staffId;
  final String workStartTime;
  final String workEndTime;
  final String? offDays; // Comma-separated or JSON array of day names
  final int maxDailyAppointments;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      'off_days': offDays,
      'max_daily_appointments': maxDailyAppointments,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory StaffSchedule.fromMap(Map<String, Object?> map) {
    return StaffSchedule(
      id: map['id'] as int?,
      staffId: map['staff_id'] as int? ?? 0,
      workStartTime: map['work_start_time'] as String? ?? '08:30',
      workEndTime: map['work_end_time'] as String? ?? '21:00',
      offDays: map['off_days'] as String?,
      maxDailyAppointments: map['max_daily_appointments'] as int? ?? 10,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  StaffSchedule copyWith({
    int? id,
    int? staffId,
    String? workStartTime,
    String? workEndTime,
    String? offDays,
    int? maxDailyAppointments,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return StaffSchedule(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      offDays: offDays ?? this.offDays,
      maxDailyAppointments: maxDailyAppointments ?? this.maxDailyAppointments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
