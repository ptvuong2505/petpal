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
    );
  }

  Future<int> _countRows(Database db, String tableName) async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
