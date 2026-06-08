import '../data/auth_dao.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository({required AuthDao dao}) : _dao = dao;

  final AuthDao _dao;

  Future<User?> login({required String email, required String password}) {
    return _dao.findByEmailAndPassword(email, password);
  }

  Future<int> register(User user) {
    return _dao.insertUser(user);
  }
}
