import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/examination_result.dart';
import '../models/staff_booking.dart';

class StaffExaminationDao {
  StaffExaminationDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const String _bookingSelect = '''
    SELECT
      b.id,
      b.user_id,
      b.pet_id,
      b.service_name,
      b.booking_date,
      b.note AS booking_note,
      b.total_price,
      b.status,
      u.full_name AS customer_name,
      u.email AS customer_email,
      u.phone AS customer_phone,
      p.name AS pet_name,
      p.species AS pet_species,
      p.breed AS pet_breed,
      p.gender AS pet_gender,
      p.birth_date AS pet_birth_date,
      p.weight AS pet_weight,
      p.note AS pet_note,
      ts.start_time,
      ts.end_time,
      hr.id AS result_id
    FROM bookings b
    INNER JOIN users u ON u.id = b.user_id
    INNER JOIN pets p ON p.id = b.pet_id
    LEFT JOIN time_slots ts ON ts.id = b.time_slot_id
    LEFT JOIN health_records hr ON hr.booking_id = b.id
  ''';

  Future<List<StaffBooking>> getBookings({String? date, String? status}) async {
    final db = await _database.database;
    final filters = <String>[];
    final arguments = <Object?>[];

    if (date != null && date.isNotEmpty) {
      filters.add('b.booking_date = ?');
      arguments.add(date);
    }
    if (status != null && status.isNotEmpty) {
      filters.add('b.status = ?');
      arguments.add(status);
    }

    final where = filters.isEmpty ? '' : 'WHERE ${filters.join(' AND ')}';
    final rows = await db.rawQuery('''
      $_bookingSelect
      $where
      ORDER BY b.booking_date ASC, ts.start_time ASC, b.id ASC
      ''', arguments);

    return rows.map(StaffBooking.fromMap).toList();
  }

  Future<StaffBooking?> getBookingDetail(int bookingId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      $_bookingSelect
      WHERE b.id = ?
      LIMIT 1
      ''',
      [bookingId],
    );

    if (rows.isEmpty) return null;
    return StaffBooking.fromMap(rows.first);
  }

  Future<List<ExaminationResult>> getResults() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT hr.*, u.full_name AS staff_name
      FROM health_records hr
      LEFT JOIN users u ON u.id = hr.staff_id
      ORDER BY hr.record_date DESC, hr.id DESC
    ''');
    return rows.map(ExaminationResult.fromMap).toList();
  }

  Future<List<ExaminationResult>> getPetHealthRecords(int petId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT hr.*, u.full_name AS staff_name
      FROM health_records hr
      LEFT JOIN users u ON u.id = hr.staff_id
      WHERE hr.pet_id = ?
      ORDER BY hr.record_date DESC, hr.id DESC
      ''',
      [petId],
    );
    return rows.map(ExaminationResult.fromMap).toList();
  }

  Future<ExaminationResult?> getResultByBooking(int bookingId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT hr.*, u.full_name AS staff_name
      FROM health_records hr
      LEFT JOIN users u ON u.id = hr.staff_id
      WHERE hr.booking_id = ?
      LIMIT 1
      ''',
      [bookingId],
    );

    if (rows.isEmpty) return null;
    return ExaminationResult.fromMap(rows.first);
  }

  Future<ExaminationResult?> getResultById(int resultId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT hr.*,
        staff.full_name AS staff_name,
        p.name AS pet_name,
        p.species AS pet_species,
        p.breed AS pet_breed,
        owner.full_name AS owner_name,
        b.service_name,
        b.booking_date,
        ts.start_time,
        ts.end_time
      FROM health_records hr
      INNER JOIN pets p ON p.id = hr.pet_id
      INNER JOIN users owner ON owner.id = p.user_id
      LEFT JOIN users staff ON staff.id = hr.staff_id
      LEFT JOIN bookings b ON b.id = hr.booking_id
      LEFT JOIN time_slots ts ON ts.id = b.time_slot_id
      WHERE hr.id = ?
      LIMIT 1
      ''',
      [resultId],
    );
    if (rows.isEmpty) return null;
    return ExaminationResult.fromMap(rows.first);
  }

  Future<int> insertResult(ExaminationResult result) async {
    final db = await _database.database;

    return db.transaction((transaction) async {
      final bookingId = result.bookingId;
      if (bookingId == null) {
        throw ArgumentError('Booking id is required');
      }

      final bookings = await transaction.query(
        'bookings',
        columns: ['id', 'status'],
        where: 'id = ?',
        whereArgs: [bookingId],
        limit: 1,
      );
      if (bookings.isEmpty) {
        throw StateError('Booking not found');
      }
      if (bookings.first['status'] == 'cancelled') {
        throw StateError('Cancelled booking cannot be completed');
      }

      final existing = await transaction.query(
        'health_records',
        columns: ['id'],
        where: 'booking_id = ?',
        whereArgs: [bookingId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw StateError('Booking already has a health record');
      }

      final resultId = await transaction.insert(
        'health_records',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await transaction.update(
        'bookings',
        {'status': 'completed', 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [bookingId],
      );
      return resultId;
    });
  }
}
