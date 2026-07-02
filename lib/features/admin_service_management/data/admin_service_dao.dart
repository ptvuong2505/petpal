import '../../../core/database/app_database.dart';
import '../../booking/models/service.dart';

class AdminServiceDao {
  AdminServiceDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Service>> getAllServices() async {
    final db = await _database.database;
    final rows = await db.query('services', orderBy: 'id DESC');
    return rows.map((row) => Service.fromMap(row)).toList();
  }

  Future<Service?> getServiceById(int id) async {
    final db = await _database.database;
    final rows = await db.query('services', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Service.fromMap(rows.first);
  }

  Future<int> insertService(Service service) async {
    final db = await _database.database;
    final now = DateTime.now().toIso8601String();
    final data = service.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data.remove('id');
    return await db.insert('services', data);
  }

  Future<int> updateService(Service service) async {
    final db = await _database.database;
    final now = DateTime.now().toIso8601String();
    final data = service.toMap();
    data['updated_at'] = now;
    return await db.update(
      'services',
      data,
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await _database.database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }
}
