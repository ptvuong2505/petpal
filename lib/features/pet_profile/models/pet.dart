class Pet {
  const Pet({
    this.id,
    this.userId,
    required this.name,
    this.species,
    this.breed,
    this.birthDate,
  });

  final int? id;
  final int? userId;
  final String name;
  final String? species;
  final String? breed;
  final DateTime? birthDate;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, Object?> map) {
    final birthDateText = map['birth_date'] as String?;
    return Pet(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      name: map['name'] as String? ?? '',
      species: map['species'] as String?,
      breed: map['breed'] as String?,
      birthDate: birthDateText == null ? null : DateTime.parse(birthDateText),
    );
  }
}
