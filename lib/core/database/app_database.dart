import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final filePath = p.join(dbPath, AppConstants.databaseName);

    return openDatabase(filePath, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // These starter tables keep the project local-only while each team member
    // builds their feature. Add columns carefully as business rules grow.
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT,
        phone TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        species TEXT,
        breed TEXT,
        birth_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        record_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        pet_id INTEGER,
        service_name TEXT NOT NULL,
        booking_date TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slot_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        is_available INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE examination_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER,
        pet_id INTEGER,
        diagnosis TEXT,
        treatment TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER,
        title TEXT NOT NULL,
        reminder_time TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shop_settings (
        id INTEGER PRIMARY KEY,
        shop_name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        open_time TEXT,
        close_time TEXT
      )
    ''');
  }
}
