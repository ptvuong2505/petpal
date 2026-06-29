// file: lib/features/booking/data/booking_dao.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../models/booking.dart';

class BookingDao {
  BookingDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  // Lấy toàn bộ danh sách nhân viên để hiển thị trên UI
  Future<List<Map<String, Object?>>> getAllStaff() async {
    final db = await _database.database;
    return db.query('users', where: 'role = ?', whereArgs: ['staff']);
  }

  // CHIỀU 1: Lấy danh sách ID nhân viên đã bị khóa hoặc đặt lịch tại một hoặc nhiều mốc thời gian
  Future<List<int>> getBusyStaffIds({
    required String date,
    required List<String> startTimes,
  }) async {
    if (startTimes.isEmpty) return [];
    final db = await _database.database;

    final placeholders = List.filled(startTimes.length, '?').join(', ');
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT DISTINCT ssa.staff_id 
      FROM staff_slot_assignments ssa
      INNER JOIN time_slots ts ON ssa.time_slot_id = ts.id
      WHERE ssa.assignment_date = ? 
        AND ts.start_time IN ($placeholders)
        AND (ssa.status = 'booked' OR ssa.booking_id IS NOT NULL)
    ''',
      [date, ...startTimes],
    );

    return rows.map((row) => row['staff_id'] as int).toList();
  }

  // CHIỀU 2: Lấy danh sách các mốc giờ (start_time) mà nhân viên đã bận thực tế trong DB
  Future<List<String>> getBusyStartTimesForStaff({
    required String date,
    required int staffId,
  }) async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT ts.start_time 
      FROM staff_slot_assignments ssa
      INNER JOIN time_slots ts ON ssa.time_slot_id = ts.id
      WHERE ssa.assignment_date = ? 
        AND ssa.staff_id = ? 
        AND (ssa.status = 'booked' OR ssa.booking_id IS NOT NULL)
    ''',
      [date, staffId],
    );

    return rows.map((row) => row['start_time'] as String).toList();
  }

  Future<List<Map<String, Object?>>> getBookingsByUserId(int userId) async {
    final db = await _database.database;
    return db.rawQuery(
      '''
      SELECT b.*, p.name as pet_name, p.species as pet_species, u.full_name as staff_name, ts.start_time, ts.end_time
      FROM bookings b
      LEFT JOIN pets p ON b.pet_id = p.id
      LEFT JOIN users u ON b.staff_id = u.id
      LEFT JOIN time_slots ts ON b.time_slot_id = ts.id
      WHERE b.user_id = ?
      ORDER BY b.booking_date DESC, b.created_at DESC
    ''',
      [userId],
    );
  }

  Future<List<Map<String, Object?>>> getAllBookingsForAdmin() async {
    final db = await _database.database;
    return db.rawQuery('''
      SELECT b.*,
             p.name AS pet_name,
             p.species AS pet_species,
             owner.full_name AS customer_name,
             owner.email AS customer_email,
             owner.phone AS customer_phone,
             staff.full_name AS staff_name,
             ts.start_time,
             ts.end_time
      FROM bookings b
      LEFT JOIN pets p ON b.pet_id = p.id
      LEFT JOIN users owner ON b.user_id = owner.id
      LEFT JOIN users staff ON b.staff_id = staff.id
      LEFT JOIN time_slots ts ON b.time_slot_id = ts.id
      ORDER BY COALESCE(b.created_at, b.booking_date) DESC, b.id DESC
    ''');
  }

  Future<Map<String, Object?>?> getBookingById(int id) async {
    final db = await _database.database;
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
      SELECT b.*, p.name as pet_name, p.species as pet_species, p.weight as pet_weight, p.image_path as pet_image,
             owner.full_name as customer_name, owner.email as customer_email, owner.phone as customer_phone,
             u.full_name as staff_name, ts.start_time, ts.end_time
      FROM bookings b
      LEFT JOIN pets p ON b.pet_id = p.id
      LEFT JOIN users owner ON b.user_id = owner.id
      LEFT JOIN users u ON b.staff_id = u.id
      LEFT JOIN time_slots ts ON b.time_slot_id = ts.id
      WHERE b.id = ?
    ''',
      [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateBookingStatus(int bookingId, String status) async {
    final db = await _database.database;
    return db.update(
      'bookings',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<List<Booking>> getBookings() async {
    final db = await _database.database;
    final rows = await db.query('bookings', orderBy: 'booking_date DESC');
    return rows.map(Booking.fromMap).toList();
  }

  Future<int> insertBooking(Booking booking) async {
    final db = await _database.database;
    return db.insert(
      'bookings',
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
