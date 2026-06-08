import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/shop_setting.dart';

class ShopSettingDao {
  ShopSettingDao({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<ShopSetting?> getSetting() async {
    final db = await _database.database;
    final rows = await db.query(
      'shop_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (rows.isEmpty) {
      return null;
    }

    return ShopSetting.fromMap(rows.first);
  }

  Future<int> saveSetting(ShopSetting setting) async {
    final db = await _database.database;
    return db.insert(
      'shop_settings',
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
