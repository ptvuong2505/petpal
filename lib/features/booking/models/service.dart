class Service {
  const Service({
    this.id,
    required this.name,
    this.description,
    this.price = 0,
    this.durationMinutes = 30,
    this.imagePath,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? imagePath;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_path': imagePath,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Service.fromMap(Map<String, Object?> map) {
    return Service(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: map['duration_minutes'] as int? ?? 30,
      imagePath: map['image_path'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
