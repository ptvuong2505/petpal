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
      LEFT JOIN pets p ON COALESCE(r.pet_id, b.pet_id) = p.id
      ORDER BY r.created_at DESC
    ''');
    return rows.map(Review.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> getAllReviewsForAdmin() async {
    final db = await _database.database;
    return db.rawQuery('''
      SELECT
        r.*,
        reviewer.full_name AS user_name,
        b.service_name,
        b.booking_date,
        b.status AS booking_status,
        p.name AS pet_name,
        staff.full_name AS staff_name
      FROM reviews r
      JOIN users reviewer ON r.user_id = reviewer.id
      JOIN bookings b ON r.booking_id = b.id
      LEFT JOIN pets p ON COALESCE(r.pet_id, b.pet_id) = p.id
      LEFT JOIN users staff ON b.staff_id = staff.id
      ORDER BY COALESCE(r.created_at, r.updated_at) DESC, r.id DESC
    ''');
  }

  Future<Map<String, Object?>?> getReviewByIdForAdmin(int id) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        r.*,
        reviewer.full_name AS user_name,
        reviewer.email AS user_email,
        reviewer.phone AS user_phone,
        b.service_name,
        b.booking_date,
        b.status AS booking_status,
        b.total_price,
        b.note AS booking_note,
        p.name AS pet_name,
        p.species AS pet_species,
        staff.full_name AS staff_name,
        ts.start_time,
        ts.end_time
      FROM reviews r
      JOIN users reviewer ON r.user_id = reviewer.id
      JOIN bookings b ON r.booking_id = b.id
      LEFT JOIN pets p ON COALESCE(r.pet_id, b.pet_id) = p.id
      LEFT JOIN users staff ON b.staff_id = staff.id
      LEFT JOIN time_slots ts ON b.time_slot_id = ts.id
      WHERE r.id = ?
      LIMIT 1
      ''',
      [id],
    );

    return rows.isEmpty ? null : rows.first;
  }

  Future<int> insertReview(Review review) async {
    final db = await _database.database;
    return db.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateReview(Review review) async {
    final db = await _database.database;
    return db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await _database.database;
    return db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }
}
