class HealthRecord {
  const HealthRecord({
    this.id,
    this.petId,
    required this.title,
    this.description,
    this.recordDate,
  });

  final int? id;
  final int? petId;
  final String title;
  final String? description;
  final DateTime? recordDate;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'description': description,
      'record_date': recordDate?.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, Object?> map) {
    final recordDateText = map['record_date'] as String?;
    return HealthRecord(
      id: map['id'] as int?,
      petId: map['pet_id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      recordDate: recordDateText == null
          ? null
          : DateTime.parse(recordDateText),
    );
  }
}
