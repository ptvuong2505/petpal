import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'database_seed.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const int schemaVersion = 2;

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
      version: schemaVersion,
      onConfigure: configure,
      onCreate: createSchema,
      onUpgrade: upgradeSchema,
    );
  }

  static Future<void> configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> createSchema(Database db, int version) async {
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
        staff_id INTEGER,
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
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE SET NULL,
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

    await _createStaffTables(db);
    await _createStaffIndexes(db);

    await DatabaseSeed.insertDefaultData(db);
  }

  static Future<void> upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE bookings ADD COLUMN staff_id INTEGER');
      await _createStaffTables(db);
      await _createStaffIndexes(db);
    }
  }

  static Future<void> _createStaffTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        specialty TEXT,
        experience_years INTEGER,
        bio TEXT,
        certificate_names TEXT,
        certificate_details TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        shift_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        request_type TEXT NOT NULL,
        source_shift_id INTEGER,
        request_note TEXT,
        review_note TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (source_shift_id) REFERENCES staff_shifts (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_notification_reads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        notification_key TEXT NOT NULL,
        read_at TEXT,
        UNIQUE (staff_id, notification_key),
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createStaffIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bookings_staff_date_status
      ON bookings (staff_id, booking_date, status)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_health_records_pet_date
      ON health_records (pet_id, record_date)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_staff_shifts_staff_date_status
      ON staff_shifts (staff_id, shift_date, status)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notification_reads_staff_key
      ON staff_notification_reads (staff_id, notification_key)
    ''');
  }
}
