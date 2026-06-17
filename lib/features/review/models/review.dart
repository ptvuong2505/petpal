class Review {
  const Review({
    this.id,
    required this.userId,
    this.petId,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int userId;
  final int? petId;
  final int bookingId;
  final int rating;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Review.fromMap(Map<String, Object?> map) {
    return Review(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      petId: map['pet_id'] as int?,
      bookingId: map['booking_id'] as int? ?? 0,
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
