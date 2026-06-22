final _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String? validateRequiredText(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

String? validateNextVisitDate(String? value, {DateTime? now}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  if (!_datePattern.hasMatch(text)) return 'Ngày tái khám không hợp lệ.';

  final date = DateTime.tryParse(text);
  if (date == null || _dateValue(date) != text) {
    return 'Ngày tái khám không hợp lệ.';
  }

  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  return date.isBefore(today)
      ? 'Ngày tái khám không được trong quá khứ.'
      : null;
}

String _dateValue(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
