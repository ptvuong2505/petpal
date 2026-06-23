final _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _timePattern = RegExp(r'^\d{2}:\d{2}$');

String? validateShiftDate(String? value, {DateTime? now}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng chọn ngày trực.';
  if (!_datePattern.hasMatch(text)) return 'Ngày phải có dạng YYYY-MM-DD.';

  final date = DateTime.tryParse(text);
  if (date == null || _dateValue(date) != text) return 'Ngày không hợp lệ.';

  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  if (date.isBefore(today)) {
    return 'Không thể đăng ký ca trực cho ngày đã qua.';
  }
  return null;
}

String? validateShiftTime(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập giờ.';
  if (!_timePattern.hasMatch(text)) return 'Giờ phải có dạng HH:mm.';

  final minutes = _minutes(text);
  return minutes == null ? 'Giờ không hợp lệ.' : null;
}

String formatShiftTime({required int hour, required int minute}) {
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String? validateShiftTimeRange({required String start, required String end}) {
  final startMinutes = _minutes(start.trim());
  final endMinutes = _minutes(end.trim());
  if (startMinutes == null || endMinutes == null) return null;
  return startMinutes >= endMinutes
      ? 'Giờ bắt đầu phải trước giờ kết thúc.'
      : null;
}

String? validateShiftNote(String? value) {
  return (value?.runes.length ?? 0) > 500 ? 'Ghi chú tối đa 500 ký tự.' : null;
}

int? _minutes(String value) {
  if (!_timePattern.hasMatch(value)) return null;
  final parts = value.split(':');
  final hour = int.tryParse(parts.first);
  final minute = int.tryParse(parts.last);
  if (hour == null || minute == null || hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

String _dateValue(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
