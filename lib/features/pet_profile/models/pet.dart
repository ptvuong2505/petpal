class Pet {
  const Pet({
    this.id,
    required this.userId,
    required this.name,
    this.species,
    this.breed,
    this.gender,
    this.birthDate,
    this.weight,
    this.imagePath,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int userId;
  final String name;
  final String? species;
  final String? breed;
  final String? gender;
  final String? birthDate;
  final double? weight;
  final String? imagePath;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birth_date': birthDate,
      'weight': weight,
      'image_path': imagePath,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Pet.fromMap(Map<String, Object?> map) {
    return Pet(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      species: map['species'] as String?,
      breed: map['breed'] as String?,
      gender: map['gender'] as String?,
      birthDate: map['birth_date'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      imagePath: map['image_path'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
