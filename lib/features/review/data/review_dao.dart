import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/review.dart';

class ReviewDao {
  ReviewDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Review>> getReviews() async {
    final db = await _database.database;
    final rows = await db.query('reviews', orderBy: 'created_at DESC');
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
