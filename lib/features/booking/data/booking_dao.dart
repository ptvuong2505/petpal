import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/booking.dart';

class BookingDao {
  BookingDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

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
