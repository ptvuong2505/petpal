import '../../booking/models/service.dart';
import '../data/admin_service_dao.dart';

class AdminServiceRepository {
  AdminServiceRepository({required AdminServiceDao dao}) : _dao = dao;

  final AdminServiceDao _dao;

  Future<List<Service>> getAllServices() => _dao.getAllServices();

  Future<Service?> getServiceById(int id) => _dao.getServiceById(id);

  Future<int> createService(Service service) => _dao.insertService(service);

  Future<int> updateService(Service service) => _dao.updateService(service);

  Future<int> deleteService(int id) => _dao.deleteService(id);
}
