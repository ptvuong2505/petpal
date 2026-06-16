import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/review.dart';

class ReviewDao {
  ReviewDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Review>> getReviews() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT r.*, u.full_name as user_name, b.service_name, p.name as pet_name
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      JOIN bookings b ON r.booking_id = b.id
      LEFT JOIN pets p ON r.pet_id = p.id
      ORDER BY r.created_at DESC
    ''');
    return rows.map(Review.fromMap).toList();
  }

  Future<int> insertReview(Review review) async {
    final db = await _database.database;
    return db.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
