// file: lib/features/booking/data/booking_dao.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../models/booking.dart';

class BookingDao {
  BookingDao({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;


  // Lấy toàn bộ danh sách nhân viên để hiển thị trên UI
  Future<List<Map<String, Object?>>> getAllStaff() async {
    final db = await _database.database;
    return db.query('users', where: 'role = ?', whereArgs: ['staff']);
  }

  // CHIỀU 1: Lấy danh sách ID nhân viên đã bị khóa hoặc đặt lịch tại một thời điểm cố định
  Future<List<int>> getBusyStaffIds({
    required String date,
    required int timeSlotId,
  }) async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'staff_slot_assignments',
      columns: ['staff_id'],
      where: 'assignment_date = ? AND time_slot_id = ? AND (status = ? OR booking_id IS NOT NULL)',
      whereArgs: [date, timeSlotId, 'booked'],
    );
    return rows.map((row) => row['staff_id'] as int).toList();
  }

  // CHIỀU 2: Lấy chi tiết các khung giờ (bao gồm start_time) mà nhân viên đã bận thực tế trong DB
  Future<List<Map<String, Object?>>> getBusySlotsDetailsForStaff({
    required String date,
    required int staffId,
  }) async {
    final db = await _database.database;
    return db.rawQuery('''
      SELECT ts.id, ts.start_time 
      FROM staff_slot_assignments ssa
      INNER JOIN time_slots ts ON ssa.time_slot_id = ts.id
      WHERE ssa.assignment_date = ? 
        AND ssa.staff_id = ? 
        AND (ssa.status = 'booked' OR ssa.booking_id IS NOT NULL)
    ''', [date, staffId]);
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