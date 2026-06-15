import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;

  setUpAll(initializeTestDatabase);

  setUp(() async {
    temporaryDirectory = await createTemporaryDatabaseDirectory();
    databasePath = temporaryDatabasePath(temporaryDirectory);
  });

  tearDown(() async {
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('migrates version 1 data to the staff portal schema', () async {
    final versionOneDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: AppDatabase.configure,
        onCreate: _createVersionOneDatabase,
      ),
    );
    await versionOneDatabase.close();

    final migratedDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion,
        onConfigure: AppDatabase.configure,
        onCreate: AppDatabase.createSchema,
        onUpgrade: AppDatabase.upgradeSchema,
      ),
    );
    addTearDown(migratedDatabase.close);

    final bookingColumns = await migratedDatabase.rawQuery(
      'PRAGMA table_info(bookings)',
    );
    expect(
      bookingColumns.map((column) => column['name']),
      contains('staff_id'),
    );

    final bookingForeignKeys = await migratedDatabase.rawQuery(
      'PRAGMA foreign_key_list(bookings)',
    );
    expect(
      bookingForeignKeys,
      contains(
        allOf(
          containsPair('from', 'staff_id'),
          containsPair('table', 'users'),
          containsPair('to', 'id'),
          containsPair('on_delete', 'SET NULL'),
        ),
      ),
    );
    expect(
      bookingForeignKeys,
      contains(
        allOf(
          containsPair('from', 'user_id'),
          containsPair('table', 'users'),
          containsPair('to', 'id'),
          containsPair('on_delete', 'CASCADE'),
        ),
      ),
    );
    expect(
      bookingForeignKeys,
      contains(
        allOf(
          containsPair('from', 'pet_id'),
          containsPair('table', 'pets'),
          containsPair('to', 'id'),
          containsPair('on_delete', 'CASCADE'),
        ),
      ),
    );

    final tables = await migratedDatabase.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final tableNames = tables.map((table) => table['name']).toSet();
    expect(tableNames, contains('staff_profiles'));
    expect(tableNames, contains('staff_shifts'));
    expect(tableNames, contains('staff_notification_reads'));

    final inferableBooking = (await migratedDatabase.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [1],
    )).single;
    expect(inferableBooking['service_name'], 'Legacy health check');
    expect(inferableBooking['status'], 'completed');
    expect(inferableBooking['staff_id'], 2);

    final unattributedBooking = (await migratedDatabase.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [2],
    )).single;
    expect(unattributedBooking['status'], 'completed');
    expect(unattributedBooking['staff_id'], isNull);

    await migratedDatabase.delete('users', where: 'id = ?', whereArgs: [2]);
    final bookingAfterStaffDeletion = (await migratedDatabase.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [1],
    )).single;
    expect(bookingAfterStaffDeletion['staff_id'], isNull);

    final indexes = await migratedDatabase.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );
    final indexNames = indexes.map((index) => index['name']).toSet();
    expect(indexNames, contains('idx_bookings_staff_date_status'));
    expect(indexNames, contains('idx_health_records_pet_date'));
    expect(indexNames, contains('idx_staff_shifts_staff_date_status'));
    expect(indexNames, contains('idx_notification_reads_staff_key'));
  });

  test('creates a new version 2 database with staff seed data', () async {
    final database = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion,
        onConfigure: AppDatabase.configure,
        onCreate: AppDatabase.createSchema,
        onUpgrade: AppDatabase.upgradeSchema,
      ),
    );
    addTearDown(database.close);

    final booking = (await database.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [2],
    )).single;
    expect(booking['staff_id'], 3);

    final profile = (await database.query(
      'staff_profiles',
      where: 'user_id = ?',
      whereArgs: [3],
    )).single;
    expect(profile['specialty'], isNotEmpty);

    final shifts = await database.query(
      'staff_shifts',
      columns: ['status'],
      where: 'staff_id = ?',
      whereArgs: [3],
    );
    expect(
      shifts.map((shift) => shift['status']).toSet(),
      containsAll(<String>{'approved', 'pending', 'rejected'}),
    );
  });
}

Future<void> _createVersionOneDatabase(Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      role TEXT NOT NULL DEFAULT 'user'
    )
  ''');
  await db.execute('''
    CREATE TABLE pets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      pet_id INTEGER NOT NULL,
      service_name TEXT NOT NULL,
      booking_date TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
      FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE health_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pet_id INTEGER NOT NULL,
      booking_id INTEGER UNIQUE,
      staff_id INTEGER,
      title TEXT NOT NULL,
      record_date TEXT,
      FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE,
      FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL,
      FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE SET NULL
    )
  ''');

  await db.insert('users', {
    'id': 1,
    'full_name': 'Legacy owner',
    'email': 'legacy@example.com',
    'role': 'user',
  });
  await db.insert('users', {
    'id': 2,
    'full_name': 'Legacy staff',
    'email': 'legacy.staff@example.com',
    'role': 'staff',
  });
  await db.insert('pets', {'id': 1, 'user_id': 1, 'name': 'Legacy pet'});
  await db.insert('bookings', {
    'id': 1,
    'user_id': 1,
    'pet_id': 1,
    'service_name': 'Legacy health check',
    'booking_date': '2026-06-01',
    'status': 'completed',
    'created_at': '2026-06-01T08:00:00.000',
    'updated_at': '2026-06-01T09:00:00.000',
  });
  await db.insert('bookings', {
    'id': 2,
    'user_id': 1,
    'pet_id': 1,
    'service_name': 'Legacy grooming',
    'booking_date': '2026-06-02',
    'status': 'completed',
    'created_at': '2026-06-02T08:00:00.000',
    'updated_at': '2026-06-02T09:00:00.000',
  });
  await db.insert('health_records', {
    'id': 1,
    'pet_id': 1,
    'booking_id': 1,
    'staff_id': 2,
    'title': 'Legacy result',
    'record_date': '2026-06-01',
  });
}
