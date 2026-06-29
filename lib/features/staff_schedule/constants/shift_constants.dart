/// Định nghĩa các ca trực cố định trong hệ thống
class ShiftType {
  final String id;
  final String name;
  final String startTime;
  final String endTime;

  const ShiftType({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  /// Chuyển đổi thành format hiển thị
  String get displayText => '$name ($startTime - $endTime)';
}

/// Danh sách các ca trực cố định
class ShiftConstants {
  static const morningShift = ShiftType(
    id: 'morning',
    name: 'Ca sáng',
    startTime: '08:00',
    endTime: '11:00',
  );

  static const afternoonShift = ShiftType(
    id: 'afternoon',
    name: 'Ca chiều',
    startTime: '13:00',
    endTime: '17:00',
  );

  /// Danh sách tất cả các ca trực
  static const List<ShiftType> allShifts = [morningShift, afternoonShift];

  /// Tìm shift type theo ID
  static ShiftType? getShiftById(String id) {
    try {
      return allShifts.firstWhere((shift) => shift.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Tìm shift type theo thời gian bắt đầu và kết thúc
  static ShiftType? getShiftByTime(String startTime, String endTime) {
    try {
      return allShifts.firstWhere(
        (shift) => shift.startTime == startTime && shift.endTime == endTime,
      );
    } catch (_) {
      return null;
    }
  }
}
