import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/pet.dart';

class PetProfileDao {
  PetProfileDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Pet>> getPetsByUserId(int userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(Pet.fromMap).toList();
  }

  Future<int> insertPet(Pet pet) async {
    final db = await _database.database;
    return db.insert(
      'pets',
      pet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deletePet(int petId) async {
    final db = await _database.database;
    return db.delete('pets', where: 'id = ?', whereArgs: [petId]);
  }
}
