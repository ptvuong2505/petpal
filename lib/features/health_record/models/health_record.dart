class HealthRecord {
  const HealthRecord({
    this.id,
    required this.petId,
    this.bookingId,
    this.staffId,
    required this.title,
    this.symptom,
    this.diagnosis,
    this.treatment,
    this.medicine,
    this.note,
    this.recordDate,
    this.nextVisitDate,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int petId;
  final int? bookingId;
  final int? staffId;
  final String title;
  final String? symptom;
  final String? diagnosis;
  final String? treatment;
  final String? medicine;
  final String? note;
  final String? recordDate;
  final String? nextVisitDate;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'booking_id': bookingId,
      'staff_id': staffId,
      'title': title,
      'symptom': symptom,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medicine': medicine,
      'note': note,
      'record_date': recordDate,
      'next_visit_date': nextVisitDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory HealthRecord.fromMap(Map<String, Object?> map) {
    return HealthRecord(
      id: map['id'] as int?,
      petId: map['pet_id'] as int? ?? 0,
      bookingId: map['booking_id'] as int?,
      staffId: map['staff_id'] as int?,
      title: map['title'] as String? ?? '',
      symptom: map['symptom'] as String?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      medicine: map['medicine'] as String?,
      note: map['note'] as String?,
      recordDate: map['record_date'] as String?,
      nextVisitDate: map['next_visit_date'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
