import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/core/database/app_database.dart';
import 'package:petpal/features/admin_shift_management/data/admin_shift_dao.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase database;
  late AdminShiftDao dao;

  setUp(() async {
    database = AppDatabase.instance;
    await database.database;
    dao = AdminShiftDao(database: database);

    final db = await database.database;
    await db.delete('staff_shifts');
    await db.delete('users');
  });

  group('AdminShiftDao', () {
    test('getShiftsInRange returns shifts within date range', () async {
      final db = await database.database;

      await db.insert('users', {
        'id': 1,
        'full_name': 'Test Staff',
        'role': 'staff',
      });

      await db.insert('staff_shifts', {
        'id': 1,
        'staff_id': 1,
        'shift_date': '2026-06-15',
        'start_time': '08:00',
        'end_time': '12:00',
        'status': 'pending',
        'request_type': 'register',
        'created_at': '2026-06-01T00:00:00.000Z',
        'updated_at': '2026-06-01T00:00:00.000Z',
      });

      final result = await dao.getShiftsInRange('2026-06-01', '2026-06-30', null);

      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.staffName, 'Test Staff');
    });

    test('approveShift updates status', () async {
      final db = await database.database;
      await db.insert('users', {'id': 1, 'full_name': 'Test', 'role': 'staff'});
      await db.insert('staff_shifts', {
        'id': 1,
        'staff_id': 1,
        'shift_date': '2026-06-15',
        'start_time': '08:00',
        'end_time': '12:00',
        'status': 'pending',
        'request_type': 'register',
      });

      await dao.approveShift(1);

      final result = await db.query('staff_shifts', where: 'id = 1');
      expect(result.first['status'], 'approved');
    });
  });
}
