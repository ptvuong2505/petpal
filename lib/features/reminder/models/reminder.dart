class Reminder {
  const Reminder({
    this.id,
    this.petId,
    required this.title,
    this.reminderTime,
    this.note,
  });

  final int? id;
  final int? petId;
  final String title;
  final DateTime? reminderTime;
  final String? note;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'reminder_time': reminderTime?.toIso8601String(),
      'note': note,
    };
  }

  factory Reminder.fromMap(Map<String, Object?> map) {
    final reminderTimeText = map['reminder_time'] as String?;
    return Reminder(
      id: map['id'] as int?,
      petId: map['pet_id'] as int?,
      title: map['title'] as String? ?? '',
      reminderTime: reminderTimeText == null
          ? null
          : DateTime.parse(reminderTimeText),
      note: map['note'] as String?,
    );
  }
}
