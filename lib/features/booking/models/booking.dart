class Booking {
  const Booking({
    this.id,
    required this.userId,
    required this.petId,
    this.serviceId,
    this.timeSlotId,
    required this.serviceName,
    this.bookingDate,
    this.note,
    this.totalPrice = 0,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int userId;
  final int petId;
  final int? serviceId;
  final int? timeSlotId;
  final String serviceName;
  final String? bookingDate;
  final String? note;
  final double totalPrice;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'service_id': serviceId,
      'time_slot_id': timeSlotId,
      'service_name': serviceName,
      'booking_date': bookingDate,
      'note': note,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Booking.fromMap(Map<String, Object?> map) {
    return Booking(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      petId: map['pet_id'] as int? ?? 0,
      serviceId: map['service_id'] as int?,
      timeSlotId: map['time_slot_id'] as int?,
      serviceName: map['service_name'] as String? ?? '',
      bookingDate: map['booking_date'] as String?,
      note: map['note'] as String?,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
