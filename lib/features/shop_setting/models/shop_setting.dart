class ShopSetting {
  const ShopSetting({
    this.id = 1,
    required this.shopName,
    this.phone,
    this.address,
    this.openTime,
    this.closeTime,
  });

  final int id;
  final String shopName;
  final String? phone;
  final String? address;
  final String? openTime;
  final String? closeTime;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'phone': phone,
      'address': address,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }

  factory ShopSetting.fromMap(Map<String, Object?> map) {
    return ShopSetting(
      id: map['id'] as int? ?? 1,
      shopName: map['shop_name'] as String? ?? 'PetPal',
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      openTime: map['open_time'] as String?,
      closeTime: map['close_time'] as String?,
    );
  }
}
