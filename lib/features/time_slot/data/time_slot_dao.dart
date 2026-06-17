import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/time_slot.dart';

class TimeSlotDao {
  TimeSlotDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<TimeSlot>> getTimeSlots() async {
    final db = await _database.database;
    final rows = await db.query('time_slots', orderBy: 'slot_date ASC');
    return rows.map(TimeSlot.fromMap).toList();
  }

  Future<int> insertTimeSlot(TimeSlot timeSlot) async {
    final db = await _database.database;
    return db.insert(
      'time_slots',
      timeSlot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
