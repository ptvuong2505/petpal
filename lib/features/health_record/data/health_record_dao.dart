import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/health_record.dart';

class HealthRecordDao {
  HealthRecordDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<HealthRecord>> getRecords() async {
    final db = await _database.database;
    final rows = await db.query('health_records', orderBy: 'record_date DESC');
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<List<HealthRecord>> getRecordsByPetId(int petId) async {
    final db = await _database.database;
    final rows = await db.query(
      'health_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'record_date DESC',
    );
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<int> insertRecord(HealthRecord record) async {
    final db = await _database.database;
    return db.insert(
      'health_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
