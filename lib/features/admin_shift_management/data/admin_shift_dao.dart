import '../../../core/database/app_database.dart';
import '../models/calendar_shift_item.dart';

class AdminShiftDao {
  AdminShiftDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<CalendarShiftItem>> getShiftsInRange(
    String startDate,
    String endDate,
    List<int>? staffIds,
  ) async {
    final db = await _database.database;

    final where = <String>[];
    final whereArgs = <Object>[startDate, endDate];

    where.add('ss.shift_date BETWEEN ? AND ?');

    if (staffIds != null && staffIds.isNotEmpty) {
      final placeholders = List.filled(staffIds.length, '?').join(',');
      where.add('ss.staff_id IN ($placeholders)');
      whereArgs.addAll(staffIds);
    }

    final rows = await db.rawQuery('''
      SELECT ss.*, u.full_name AS staff_name
      FROM staff_shifts ss
      INNER JOIN users u ON u.id = ss.staff_id
      WHERE ${where.join(' AND ')}
      ORDER BY ss.shift_date, ss.start_time
    ''', whereArgs);

    return rows.map((row) => CalendarShiftItem.fromMap(row)).toList();
  }

  Future<void> approveShift(int shiftId) async {
    final db = await _database.database;
    await db.update(
      'staff_shifts',
      {'status': 'approved', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<void> rejectShift(int shiftId) async {
    final db = await _database.database;
    await db.update(
      'staff_shifts',
      {'status': 'rejected', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<int> assignShift({
    required int staffId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    if (startTime.compareTo(endTime) >= 0) {
      throw ArgumentError('End time must be after start time');
    }

    final db = await _database.database;
    final now = DateTime.now().toIso8601String();

    return db.insert('staff_shifts', {
      'staff_id': staffId,
      'shift_date': date,
      'start_time': startTime,
      'end_time': endTime,
      'status': 'approved',
      'request_type': 'admin_assign',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<bool> checkConflict({
    required int staffId,
    required String date,
    required String startTime,
    required String endTime,
    int? excludeShiftId,
  }) async {
    final db = await _database.database;

    final where = <String>[
      'staff_id = ?',
      'shift_date = ?',
      "status IN ('approved', 'pending')",
      'start_time < ?',
      'end_time > ?',
    ];
    final whereArgs = <Object>[staffId, date, endTime, startTime];

    if (excludeShiftId != null) {
      where.add('id != ?');
      whereArgs.add(excludeShiftId);
    }

    final conflicts = await db.query(
      'staff_shifts',
      where: where.join(' AND '),
      whereArgs: whereArgs,
    );

    return conflicts.isNotEmpty;
  }

  Future<List<Map<String, Object?>>> getAllStaff() async {
    final db = await _database.database;
    return db.query(
      'users',
      columns: ['id', 'full_name', 'email'],
      where: "role = 'staff'",
      orderBy: 'full_name',
    );
  }
}
