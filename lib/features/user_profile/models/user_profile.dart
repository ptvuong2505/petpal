class UserProfile {
  const UserProfile({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
  });

  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? address;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      address: map['address'] as String?,
    );
  }
}
