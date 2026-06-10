import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'database_seed.dart';

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

    return openDatabase(
      filePath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT,
        phone TEXT,
        address TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        species TEXT,
        breed TEXT,
        gender TEXT,
        birth_date TEXT,
        weight REAL,
        image_path TEXT,
        note TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL DEFAULT 0,
        duration_minutes INTEGER NOT NULL DEFAULT 30,
        image_path TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slot_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        max_booking INTEGER NOT NULL DEFAULT 1,
        booked_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'available',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        pet_id INTEGER NOT NULL,
        service_id INTEGER,
        time_slot_id INTEGER,
        service_name TEXT NOT NULL,
        booking_date TEXT,
        note TEXT,
        total_price REAL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE SET NULL,
        FOREIGN KEY (time_slot_id) REFERENCES time_slots (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        booking_id INTEGER UNIQUE,
        staff_id INTEGER,
        title TEXT NOT NULL,
        symptom TEXT,
        diagnosis TEXT,
        treatment TEXT,
        medicine TEXT,
        note TEXT,
        record_date TEXT,
        next_visit_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE,
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL,
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        pet_id INTEGER,
        booking_id INTEGER NOT NULL UNIQUE,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE SET NULL,
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        pet_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        type TEXT,
        reminder_time TEXT,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE shop_settings (
        id INTEGER PRIMARY KEY,
        shop_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        open_time TEXT,
        close_time TEXT,
        description TEXT,
        booking_policy TEXT,
        logo_path TEXT,
        updated_at TEXT
      )
    ''');

    await DatabaseSeed.insertDefaultData(db);
  }
}
