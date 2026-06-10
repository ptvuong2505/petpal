class User {
  const User({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String fullName;
  final String email;
  final String? password;
  final String? phone;
  final String? address;
  final String role;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
      role: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? role,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
