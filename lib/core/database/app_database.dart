// file: lib/core/database/app_database.dart
import 'package:path/path.dart' as p; //
import 'package:sqflite/sqflite.dart'; //

import '../constants/app_constants.dart'; //
import 'database_seed.dart'; //

class AppDatabase {
  AppDatabase._(); //

  static final AppDatabase instance = AppDatabase._(); //
  static const int schemaVersion = 3; //

  Database? _database;
  // Khai báo thêm biến Future để giữ trạng thái mở DB, chống tình trạng Deadlock khi gọi đồng thời
  Future<Database>? _openDatabaseFuture;

  Future<Database> get database async {
    if (_database != null) {
      return _database!; //
    }

    // Nếu database đang trong quá trình mở bởi một tiến trình khác, đợi tiến trình đó hoàn thành
    _openDatabaseFuture ??= _openDatabase();
    _database = await _openDatabaseFuture;

    return _database!; //
  }

  Future<Database> _openDatabase() async {
    //
    final dbPath = await getDatabasesPath(); //
    final filePath = p.join(dbPath, AppConstants.databaseName); //

    return openDatabase(
      //
      filePath, //
      version: schemaVersion, //
      onConfigure: configure, //
      onCreate: createSchema, //
      onUpgrade: upgradeSchema, //
    ); //
  }

  static Future<void> configure(Database db) async {
    //
    await db.execute('PRAGMA foreign_keys = ON'); //
  }

  static Future<void> createSchema(Database db, int version) async {
    //
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
    '''); //

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
    '''); //

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
    '''); //

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
    '''); //

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        pet_id INTEGER NOT NULL,
        service_id INTEGER,
        time_slot_id INTEGER,
        staff_id INTEGER, 
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
        FOREIGN KEY (time_slot_id) REFERENCES time_slots (id) ON DELETE SET NULL,
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE SET NULL
      )
    '''); //

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
    '''); //

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
    '''); //

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
    '''); //

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
    '''); //

    await db.execute('''
      CREATE TABLE staff_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL UNIQUE,
        work_start_time TEXT NOT NULL DEFAULT '08:30',
        work_end_time TEXT NOT NULL DEFAULT '21:00',
        off_days TEXT,
        max_daily_appointments INTEGER DEFAULT 10,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE
      )
    '''); //

    await db.execute('''
      CREATE TABLE staff_slot_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        time_slot_id INTEGER NOT NULL,
        booking_id INTEGER,
        assignment_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'available',
        created_at TEXT,
        updated_at TEXT,
        UNIQUE(staff_id, time_slot_id, assignment_date),
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (time_slot_id) REFERENCES time_slots (id) ON DELETE CASCADE,
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL
      )
    '''); //

    await _createStaffTables(db); //
    await _createStaffIndexes(db); //

    await DatabaseSeed.insertDefaultData(db); //
  }

  static Future<void> upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // 1. Tạo các bảng nghiệp vụ mới của V2 TRƯỚC (để tránh lỗi Foreign Key khi tạo bảng bookings)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS services (
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
        CREATE TABLE IF NOT EXISTS time_slots (
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

      // 2. Khởi tạo bảng bookings mới với đầy đủ ràng buộc khóa ngoại (SQLite không hỗ trợ ADD COLUMN kèm FOREIGN KEY)
      // Sử dụng quy trình: Đổi tên bảng cũ -> Tạo bảng mới chuẩn V2 -> Chép dữ liệu -> Xóa bảng cũ
      await db.execute('ALTER TABLE bookings RENAME TO bookings_old');

      await db.execute('''
        CREATE TABLE bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          pet_id INTEGER NOT NULL,
          service_id INTEGER,
          time_slot_id INTEGER,
          staff_id INTEGER, 
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
          FOREIGN KEY (time_slot_id) REFERENCES time_slots (id) ON DELETE SET NULL,
          FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE SET NULL
        )
      ''');

      // 3. Chuyển dữ liệu từ bảng cũ sang bảng mới
      await db.execute('''
        INSERT INTO bookings (id, user_id, pet_id, service_name, booking_date, status, created_at, updated_at)
        SELECT id, user_id, pet_id, service_name, booking_date, status, created_at, updated_at
        FROM bookings_old
      ''');

      // 4. Cập nhật staff_id từ health_records (Logic di trú dữ liệu cũ sang hệ thống Staff Portal)
      await db.execute('''
        UPDATE bookings
        SET staff_id = (
          SELECT hr.staff_id
          FROM health_records hr
          WHERE hr.booking_id = bookings.id
            AND hr.staff_id IS NOT NULL
          LIMIT 1
        )
        WHERE EXISTS (
          SELECT 1
          FROM health_records hr
          WHERE hr.booking_id = bookings.id
            AND hr.staff_id IS NOT NULL
        )
      ''');

      await db.execute('DROP TABLE bookings_old');

      // 5. Tạo các bảng mới bổ sung cho tính năng Staff Portal và các bảng mới khác của V2
      await _createStaffTables(db);
      await _createStaffIndexes(db);

      // Bổ sung các cột thiếu cho các bảng hiện có (nếu từ V1 lên)
      try {
        await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN address TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN created_at TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN updated_at TEXT');
      } catch (_) {}

      try {
        await db.execute('ALTER TABLE health_records ADD COLUMN symptom TEXT');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE health_records ADD COLUMN diagnosis TEXT',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE health_records ADD COLUMN treatment TEXT',
        );
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE health_records ADD COLUMN medicine TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE health_records ADD COLUMN note TEXT');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE health_records ADD COLUMN next_visit_date TEXT',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE health_records ADD COLUMN created_at TEXT',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE health_records ADD COLUMN updated_at TEXT',
        );
      } catch (_) {}

      // Tạo các bảng nghiệp vụ mới còn lại của V2
      // Xóa và tạo lại để đảm bảo Foreign Key trỏ đúng vào bảng bookings mới (tránh lỗi bookings_old)
      await db.execute('DROP TABLE IF EXISTS reviews');
      await db.execute(
        'CREATE TABLE reviews (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, pet_id INTEGER, booking_id INTEGER NOT NULL UNIQUE, rating INTEGER NOT NULL, comment TEXT, created_at TEXT, updated_at TEXT, FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE, FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE SET NULL, FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE)',
      );
      await db.execute('DROP TABLE IF EXISTS reminders');
      await db.execute(
        'CREATE TABLE reminders (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, pet_id INTEGER NOT NULL, title TEXT NOT NULL, type TEXT, reminder_time TEXT, note TEXT, status TEXT NOT NULL DEFAULT "pending", created_at TEXT, updated_at TEXT, FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE, FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS shop_settings (id INTEGER PRIMARY KEY, shop_name TEXT NOT NULL, phone TEXT, email TEXT, address TEXT, open_time TEXT, close_time TEXT, description TEXT, booking_policy TEXT, logo_path TEXT, updated_at TEXT)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS staff_schedules (id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL UNIQUE, work_start_time TEXT NOT NULL DEFAULT "08:30", work_end_time TEXT NOT NULL DEFAULT "21:00", off_days TEXT, max_daily_appointments INTEGER DEFAULT 10, notes TEXT, created_at TEXT, updated_at TEXT, FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS staff_slot_assignments (id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL, time_slot_id INTEGER NOT NULL, booking_id INTEGER, assignment_date TEXT NOT NULL, status TEXT NOT NULL DEFAULT "available", created_at TEXT, updated_at TEXT, UNIQUE(staff_id, time_slot_id, assignment_date), FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE, FOREIGN KEY (time_slot_id) REFERENCES time_slots (id) ON DELETE CASCADE, FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL)',
      );
    }

    if (oldVersion < 3) {
      // Fix lỗi ràng buộc khóa ngoại trỏ vào bảng bookings_old đã bị xóa
      // Chúng ta sẽ tạo lại các bảng này để đảm bảo chúng trỏ đúng vào bảng bookings hiện tại
      await db.execute('ALTER TABLE reviews RENAME TO reviews_old');
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
      try {
        await db.execute('INSERT INTO reviews SELECT * FROM reviews_old');
      } catch (_) {}
      await db.execute('DROP TABLE reviews_old');

      await db.execute('DROP TABLE IF EXISTS reminders');
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

      // Sửa bảng health_records vì nó cũng có khóa ngoại tới bookings
      await db.execute(
        'ALTER TABLE health_records RENAME TO health_records_old',
      );
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
        INSERT INTO health_records 
        SELECT * FROM health_records_old
      ''');
      await db.execute('DROP TABLE health_records_old');
    }
  }

  static Future<void> _createStaffTables(Database db) async {
    //
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
    '''); //

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
    '''); //

    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_notification_reads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        notification_key TEXT NOT NULL,
        read_at TEXT,
        UNIQUE (staff_id, notification_key),
        FOREIGN KEY (staff_id) REFERENCES users (id) ON DELETE CASCADE
      )
    '''); //
  }

  static Future<void> _createStaffIndexes(Database db) async {
    //
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bookings_staff_date_status
      ON bookings (staff_id, booking_date, status)
    '''); //
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_health_records_pet_date
      ON health_records (pet_id, record_date)
    '''); //
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_staff_shifts_staff_date_status
      ON staff_shifts (staff_id, shift_date, status)
    '''); //
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notification_reads_staff_key
      ON staff_notification_reads (staff_id, notification_key)
    '''); //
  }
}
