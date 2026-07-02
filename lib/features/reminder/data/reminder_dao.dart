import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/reminder.dart';

class ReminderDao {
  ReminderDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Reminder>> getReminders() async {
    final db = await _database.database;
    final rows = await db.query('reminders', orderBy: 'reminder_time ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await _database.database;
    return db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
