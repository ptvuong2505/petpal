class User {
  const User({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    this.phone,
    this.address,
  });

  final int? id;
  final String fullName;
  final String email;
  final String? password;
  final String? phone;
  final String? address;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
    );
  }
}
