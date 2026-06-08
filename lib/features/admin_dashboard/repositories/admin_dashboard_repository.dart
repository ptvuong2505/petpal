import '../data/admin_dashboard_dao.dart';
import '../models/dashboard_summary.dart';

class AdminDashboardRepository {
  AdminDashboardRepository({required AdminDashboardDao dao}) : _dao = dao;

  final AdminDashboardDao _dao;

  Future<DashboardSummary> getSummary() {
    return _dao.getSummary();
  }
}
