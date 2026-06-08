class DateTimeHelper {
  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  static String toDatabaseValue(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
