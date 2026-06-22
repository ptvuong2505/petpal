class ExaminationResult {
  const ExaminationResult({
    this.id,
    this.bookingId,
    required this.petId,
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
    this.staffName,
    this.petName,
    this.petSpecies,
    this.petBreed,
    this.ownerName,
    this.serviceName,
    this.bookingDate,
    this.startTime,
    this.endTime,
  });

  final int? id;
  final int? bookingId;
  final int petId;
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
  final String? staffName;
  final String? petName;
  final String? petSpecies;
  final String? petBreed;
  final String? ownerName;
  final String? serviceName;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'pet_id': petId,
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

  factory ExaminationResult.fromMap(Map<String, Object?> map) {
    return ExaminationResult(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      petId: map['pet_id'] as int? ?? 0,
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
      staffName: map['staff_name'] as String?,
      petName: map['pet_name'] as String?,
      petSpecies: map['pet_species'] as String?,
      petBreed: map['pet_breed'] as String?,
      ownerName: map['owner_name'] as String?,
      serviceName: map['service_name'] as String?,
      bookingDate: map['booking_date'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
    );
  }
}
