class Review {
  const Review({
    this.id,
    this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final int? id;
  final int? bookingId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, Object?> map) {
    final createdAtText = map['created_at'] as String?;
    return Review(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String?,
      createdAt: createdAtText == null ? null : DateTime.parse(createdAtText),
    );
  }
}
