import '../data/health_record_dao.dart';
import '../models/health_record.dart';

class HealthRecordRepository {
  HealthRecordRepository({required HealthRecordDao dao}) : _dao = dao;

  final HealthRecordDao _dao;

  Future<List<HealthRecord>> getRecords() {
    return _dao.getRecords();
  }

  Future<List<HealthRecord>> getRecordsByPetId(int petId) {
    return _dao.getRecordsByPetId(petId);
  }

  Future<int> addRecord(HealthRecord record) {
    return _dao.insertRecord(record);
  }
}
