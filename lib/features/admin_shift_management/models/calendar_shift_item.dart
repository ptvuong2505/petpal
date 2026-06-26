class CalendarShiftItem {
  const CalendarShiftItem({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.requestType,
    this.requestNote,
    this.adminNote,
  });

  final int id;
  final int staffId;
  final String staffName;
  final String shiftDate; // YYYY-MM-DD
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String status; // 'pending' | 'approved' | 'rejected'
  final String requestType; // 'register' | 'admin_assign'
  final String? requestNote;
  final String? adminNote;

  factory CalendarShiftItem.fromMap(Map<String, Object?> map) {
    return CalendarShiftItem(
      id: map['id'] as int,
      staffId: map['staff_id'] as int,
      staffName: map['staff_name'] as String? ?? '',
      shiftDate: map['shift_date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      status: map['status'] as String,
      requestType: map['request_type'] as String,
      requestNote: map['request_note'] as String?,
      adminNote: map['admin_note'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'staff_name': staffName,
      'shift_date': shiftDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'request_type': requestType,
      'request_note': requestNote,
      'admin_note': adminNote,
    };
  }
}
