class Reminder {
  const Reminder({
    this.id,
    this.userId,
    required this.petId,
    required this.title,
    this.type,
    this.reminderTime,
    this.note,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int petId;
  final String title;
  final String? type;
  final String? reminderTime;
  final String? note;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'title': title,
      'type': type,
      'reminder_time': reminderTime,
      'note': note,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Reminder.fromMap(Map<String, Object?> map) {
    return Reminder(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      petId: map['pet_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      type: map['type'] as String?,
      reminderTime: map['reminder_time'] as String?,
      note: map['note'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
