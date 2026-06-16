class StaffBooking {
  const StaffBooking({
    required this.id,
    required this.userId,
    required this.petId,
    required this.serviceName,
    this.bookingDate,
    this.status = 'pending',
    this.bookingNote,
    this.totalPrice = 0,
    this.customerName = '',
    this.customerEmail,
    this.customerPhone,
    this.petName = '',
    this.petSpecies,
    this.petBreed,
    this.petGender,
    this.petBirthDate,
    this.petWeight,
    this.petNote,
    this.startTime,
    this.endTime,
    this.resultId,
  });

  final int id;
  final int userId;
  final int petId;
  final String serviceName;
  final String? bookingDate;
  final String status;
  final String? bookingNote;
  final double totalPrice;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String petName;
  final String? petSpecies;
  final String? petBreed;
  final String? petGender;
  final String? petBirthDate;
  final double? petWeight;
  final String? petNote;
  final String? startTime;
  final String? endTime;
  final int? resultId;

  bool get hasResult => resultId != null;

  factory StaffBooking.fromMap(Map<String, Object?> map) {
    return StaffBooking(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      petId: map['pet_id'] as int? ?? 0,
      serviceName: map['service_name'] as String? ?? '',
      bookingDate: map['booking_date'] as String?,
      status: map['status'] as String? ?? 'pending',
      bookingNote: map['booking_note'] as String?,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      customerName: map['customer_name'] as String? ?? '',
      customerEmail: map['customer_email'] as String?,
      customerPhone: map['customer_phone'] as String?,
      petName: map['pet_name'] as String? ?? '',
      petSpecies: map['pet_species'] as String?,
      petBreed: map['pet_breed'] as String?,
      petGender: map['pet_gender'] as String?,
      petBirthDate: map['pet_birth_date'] as String?,
      petWeight: (map['pet_weight'] as num?)?.toDouble(),
      petNote: map['pet_note'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      resultId: map['result_id'] as int?,
    );
  }
}
