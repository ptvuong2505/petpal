import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/dashboard_summary.dart';

class AdminDashboardDao {
  AdminDashboardDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<DashboardSummary> getSummary() async {
    final db = await _database.database;
    return DashboardSummary(
      totalPets: await _countRows(db, 'pets'),
      totalBookings: await _countRows(db, 'bookings'),
      totalReviews: await _countRows(db, 'reviews'),
      openTasks: await _countOpenTasks(db),
      dailyBookings: await _getDailyBookings(db),
      recentBookings: await _getRecentBookings(db),
      recentReviews: await _getRecentReviews(db),
    );
  }

  Future<int> _countRows(Database db, String tableName) async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> _countOpenTasks(Database db) async {
    final result = await db.rawQuery('''
      SELECT COUNT(*)
      FROM bookings
      WHERE status IN ('pending', 'confirmed')
      ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<DailyBookingCount>> _getDailyBookings(Database db) async {
    final today = DateTime.now();
    final startDate = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final endDate = startDate.add(const Duration(days: 6));
    final rows = await db.rawQuery(
      '''
      SELECT booking_date, COUNT(*) AS booking_count
      FROM bookings
      WHERE booking_date BETWEEN ? AND ?
      GROUP BY booking_date
      ORDER BY booking_date ASC
      ''',
      [_dateValue(startDate), _dateValue(endDate)],
    );

    final countsByDate = <String, int>{
      for (final row in rows)
        row['booking_date'] as String: row['booking_count'] as int? ?? 0,
    };

    return List.generate(7, (index) {
      final date = startDate.add(Duration(days: index));
      return DailyBookingCount(
        date: date,
        count: countsByDate[_dateValue(date)] ?? 0,
      );
    });
  }

  Future<List<RecentBooking>> _getRecentBookings(Database db) async {
    final rows = await db.rawQuery('''
      SELECT
        b.service_name,
        b.booking_date,
        b.status,
        p.name AS pet_name,
        ts.start_time
      FROM bookings b
      INNER JOIN pets p ON p.id = b.pet_id
      LEFT JOIN time_slots ts ON ts.id = b.time_slot_id
      ORDER BY COALESCE(b.updated_at, b.created_at, b.booking_date) DESC, b.id DESC
      LIMIT 3
      ''');

    return rows.map((row) {
      return RecentBooking(
        serviceName: row['service_name'] as String? ?? 'Dịch vụ',
        petName: row['pet_name'] as String? ?? 'Pet',
        bookingDate: row['booking_date'] as String? ?? '',
        startTime: row['start_time'] as String?,
        status: row['status'] as String? ?? 'pending',
      );
    }).toList();
  }

  Future<List<RecentReview>> _getRecentReviews(Database db) async {
    final rows = await db.rawQuery('''
      SELECT
        r.rating,
        r.comment,
        r.created_at,
        u.full_name AS customer_name
      FROM reviews r
      INNER JOIN users u ON u.id = r.user_id
      ORDER BY COALESCE(r.created_at, r.updated_at) DESC, r.id DESC
      LIMIT 2
      ''');

    return rows.map((row) {
      return RecentReview(
        customerName: row['customer_name'] as String? ?? 'Khách hàng',
        rating: row['rating'] as int? ?? 0,
        comment: row['comment'] as String? ?? '',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
      );
    }).toList();
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
