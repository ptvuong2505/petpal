import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

class StaffPortalDao {
  StaffPortalDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Map<String, Object?>>> searchPets(String query) async {
    final db = await _database.database;
    final text = '%${query.trim().toLowerCase()}%';
    return db.rawQuery(
      '''
      SELECT p.*, u.full_name AS owner_name, u.email AS owner_email,
        u.phone AS owner_phone, COUNT(hr.id) AS record_count
      FROM pets p
      INNER JOIN users u ON u.id = p.user_id
      LEFT JOIN health_records hr ON hr.pet_id = p.id
      WHERE ? = '%%' OR LOWER(p.name) LIKE ? OR LOWER(u.full_name) LIKE ?
        OR LOWER(u.email) LIKE ? OR LOWER(COALESCE(u.phone, '')) LIKE ?
      GROUP BY p.id
      ORDER BY p.name
      ''',
      [text, text, text, text, text],
    );
  }

  Future<Map<String, Object?>?> petDetail(int petId) async {
    final db = await _database.database;
    final pets = await db.rawQuery(
      '''SELECT p.*, u.full_name AS owner_name, u.email AS owner_email,
        u.phone AS owner_phone FROM pets p INNER JOIN users u ON u.id=p.user_id
        WHERE p.id=? LIMIT 1''',
      [petId],
    );
    if (pets.isEmpty) return null;
    final records = await db.rawQuery(
      '''SELECT hr.*, u.full_name AS staff_name FROM health_records hr
        LEFT JOIN users u ON u.id=hr.staff_id WHERE hr.pet_id=?
        ORDER BY hr.record_date DESC, hr.id DESC''',
      [petId],
    );
    return {...pets.first, 'records': records};
  }

  Future<List<Map<String, Object?>>> schedule(
    int staffId,
    String from,
    String to,
  ) async {
    final db = await _database.database;
    final shifts = await db.rawQuery(
      '''SELECT id, shift_date AS event_date, start_time, end_time, status,
        request_type, 'shift' AS event_type, 'Ca trực' AS title
        FROM staff_shifts WHERE staff_id=? AND shift_date BETWEEN ? AND ?''',
      [staffId, from, to],
    );
    final bookings = await db.rawQuery(
      '''SELECT b.id, b.booking_date AS event_date, ts.start_time, ts.end_time,
        b.status, 'appointment' AS event_type,
        b.service_name || ' - ' || p.name AS title
        FROM bookings b INNER JOIN pets p ON p.id=b.pet_id
        LEFT JOIN time_slots ts ON ts.id=b.time_slot_id
        WHERE b.staff_id=? AND b.booking_date BETWEEN ? AND ?''',
      [staffId, from, to],
    );
    return [...shifts, ...bookings]..sort(
      (a, b) => '${a['event_date']}${a['start_time']}'.compareTo(
        '${b['event_date']}${b['start_time']}',
      ),
    );
  }

  Future<int> requestShift({
    required int staffId,
    required String date,
    required String start,
    required String end,
    required String note,
  }) async {
    if (start.compareTo(end) >= 0) {
      throw StateError('Giờ kết thúc không hợp lệ.');
    }
    final db = await _database.database;
    final conflicts = await db.rawQuery(
      '''SELECT id FROM staff_shifts WHERE staff_id=? AND shift_date=?
        AND status IN ('approved','pending') AND start_time < ? AND end_time > ?''',
      [staffId, date, end, start],
    );
    if (conflicts.isNotEmpty) throw StateError('Ca làm việc bị trùng lịch.');
    final now = DateTime.now().toIso8601String();
    return db.insert('staff_shifts', {
      'staff_id': staffId,
      'shift_date': date,
      'start_time': start,
      'end_time': end,
      'status': 'pending',
      'request_type': 'register',
      'request_note': note,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<Map<String, Object?>?> staffProfile(int staffId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''SELECT u.id AS user_id, u.full_name, u.email, u.phone, sp.*
        FROM users u LEFT JOIN staff_profiles sp ON sp.user_id=u.id
        WHERE u.id=? LIMIT 1''',
      [staffId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveProfile({
    required int staffId,
    required String specialty,
    required int experienceYears,
    required String bio,
    required List<String> certificates,
  }) async {
    final db = await _database.database;
    final now = DateTime.now().toIso8601String();
    await db.insert('staff_profiles', {
      'user_id': staffId,
      'specialty': specialty,
      'experience_years': experienceYears,
      'bio': bio,
      'certificate_names': jsonEncode(certificates),
      'certificate_details': '[]',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> notifications(int staffId) async {
    final db = await _database.database;
    final bookings = await db.rawQuery(
      '''SELECT 'booking-' || id AS notification_key, created_at AS event_time,
        CASE WHEN status='cancelled' THEN 'Lịch hẹn đã hủy' ELSE 'Lịch hẹn mới' END AS title,
        service_name AS message, status, id AS source_id
        FROM bookings WHERE staff_id=? AND status IN ('pending','confirmed','cancelled')''',
      [staffId],
    );
    final shifts = await db.rawQuery(
      '''SELECT 'shift-' || id AS notification_key, updated_at AS event_time,
        'Cập nhật ca trực' AS title,
        shift_date || ' ' || start_time || '-' || end_time AS message,
        status, id AS source_id FROM staff_shifts WHERE staff_id=?''',
      [staffId],
    );
    final reads = await db.query(
      'staff_notification_reads',
      columns: ['notification_key'],
      where: 'staff_id=?',
      whereArgs: [staffId],
    );
    final readKeys = reads.map((row) => row['notification_key']).toSet();
    final items = [...bookings, ...shifts]
        .map(
          (row) => {
            ...row,
            'is_read': readKeys.contains(row['notification_key']),
          },
        )
        .toList();
    items.sort((a, b) => '${b['event_time']}'.compareTo('${a['event_time']}'));
    return items;
  }

  Future<void> markRead(int staffId, String key) async {
    final db = await _database.database;
    await db.insert('staff_notification_reads', {
      'staff_id': staffId,
      'notification_key': key,
      'read_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, Object?>> statistics(
    int staffId,
    String from,
    String to,
  ) async {
    final db = await _database.database;
    final summary = (await db.rawQuery(
      '''SELECT COUNT(*) AS assigned,
        SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed
        FROM bookings WHERE staff_id=? AND booking_date BETWEEN ? AND ?''',
      [staffId, from, to],
    )).first;
    final examinations =
        Sqflite.firstIntValue(
          await db.rawQuery(
            '''SELECT COUNT(*) FROM health_records WHERE staff_id=?
          AND record_date BETWEEN ? AND ?''',
            [staffId, from, to],
          ),
        ) ??
        0;
    final rating = (await db.rawQuery(
      '''SELECT AVG(r.rating) AS average_rating, COUNT(r.id) AS rating_count
        FROM reviews r INNER JOIN bookings b ON b.id=r.booking_id
        WHERE b.staff_id=? AND b.booking_date BETWEEN ? AND ?''',
      [staffId, from, to],
    )).first;
    final feedback = await db.rawQuery(
      '''SELECT r.rating, r.comment, r.created_at, p.name AS pet_name
        FROM reviews r INNER JOIN bookings b ON b.id=r.booking_id
        LEFT JOIN pets p ON p.id=r.pet_id WHERE b.staff_id=?
        ORDER BY r.created_at DESC LIMIT 10''',
      [staffId],
    );
    return {
      ...summary,
      'examinations': examinations,
      ...rating,
      'feedback': feedback,
    };
  }
}
