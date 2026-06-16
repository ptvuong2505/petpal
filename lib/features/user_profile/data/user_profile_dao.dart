import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../models/user_profile.dart';

class UserProfileDao {
  UserProfileDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<UserProfile?> getFirstProfile() async {
    final db = await _database.database;
    final rows = await db.query('users', limit: 1);

    if (rows.isEmpty) {
      return null;
    }
    return UserProfile.fromMap(rows.first);
  }

  Future<int> saveProfile(UserProfile profile) async {
    final db = await _database.database;
    return db.insert(
      'users',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
