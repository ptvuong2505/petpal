class ExaminationResult {
  const ExaminationResult({
    this.id,
    this.bookingId,
    this.petId,
    this.diagnosis,
    this.treatment,
    this.createdAt,
  });

  final int? id;
  final int? bookingId;
  final int? petId;
  final String? diagnosis;
  final String? treatment;
  final DateTime? createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'pet_id': petId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ExaminationResult.fromMap(Map<String, Object?> map) {
    final createdAtText = map['created_at'] as String?;
    return ExaminationResult(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      petId: map['pet_id'] as int?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      createdAt: createdAtText == null ? null : DateTime.parse(createdAtText),
    );
  }
}
