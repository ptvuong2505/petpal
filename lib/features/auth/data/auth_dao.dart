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
      conflictAlgorithm: ConflictAlgorithm.replace,
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
