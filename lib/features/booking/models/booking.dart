class Booking {
  const Booking({
    this.id,
    this.userId,
    this.petId,
    required this.serviceName,
    this.bookingDate,
    this.status,
  });

  final int? id;
  final int? userId;
  final int? petId;
  final String serviceName;
  final DateTime? bookingDate;
  final String? status;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'service_name': serviceName,
      'booking_date': bookingDate?.toIso8601String(),
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, Object?> map) {
    final bookingDateText = map['booking_date'] as String?;
    return Booking(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      petId: map['pet_id'] as int?,
      serviceName: map['service_name'] as String? ?? '',
      bookingDate: bookingDateText == null
          ? null
          : DateTime.parse(bookingDateText),
      status: map['status'] as String?,
    );
  }
}
