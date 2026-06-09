class ShopSetting {
  const ShopSetting({
    this.id = 1,
    required this.shopName,
    this.phone,
    this.email,
    this.address,
    this.openTime,
    this.closeTime,
    this.description,
    this.bookingPolicy,
    this.logoPath,
    this.updatedAt,
  });

  final int id;
  final String shopName;
  final String? phone;
  final String? email;
  final String? address;
  final String? openTime;
  final String? closeTime;
  final String? description;
  final String? bookingPolicy;
  final String? logoPath;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'phone': phone,
      'email': email,
      'address': address,
      'open_time': openTime,
      'close_time': closeTime,
      'description': description,
      'booking_policy': bookingPolicy,
      'logo_path': logoPath,
      'updated_at': updatedAt,
    };
  }

  factory ShopSetting.fromMap(Map<String, Object?> map) {
    return ShopSetting(
      id: map['id'] as int? ?? 1,
      shopName: map['shop_name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      openTime: map['open_time'] as String?,
      closeTime: map['close_time'] as String?,
      description: map['description'] as String?,
      bookingPolicy: map['booking_policy'] as String?,
      logoPath: map['logo_path'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
