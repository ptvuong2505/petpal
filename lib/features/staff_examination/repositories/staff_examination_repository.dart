import '../data/staff_examination_dao.dart';
import '../models/examination_result.dart';

class StaffExaminationRepository {
  StaffExaminationRepository({required StaffExaminationDao dao}) : _dao = dao;

  final StaffExaminationDao _dao;

  Future<List<ExaminationResult>> getResults() {
    return _dao.getResults();
  }

  Future<int> createResult(ExaminationResult result) {
    return _dao.insertResult(result);
  }
}
