import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/examination_result.dart';

class StaffExaminationDao {
  StaffExaminationDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<ExaminationResult>> getResults() async {
    final db = await _database.database;
    final rows = await db.query(
      'examination_results',
      orderBy: 'created_at DESC',
    );
    return rows.map(ExaminationResult.fromMap).toList();
  }

  Future<int> insertResult(ExaminationResult result) async {
    final db = await _database.database;
    return db.insert(
      'examination_results',
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
