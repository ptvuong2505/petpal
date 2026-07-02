import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/user.dart';

class AuthDao {
  AuthDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  Future<int> insertUser(User user) async {
    final db = await _database.database;
    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<User?> findByEmail(String email) async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }

  Future<User?> findByPhone(String phone) async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }

  Future<int> updateUser(User user) async {
    final db = await _database.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<User?> findByEmailAndPassword(String email, String password) async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return User.fromMap(rows.first);
  }
}
