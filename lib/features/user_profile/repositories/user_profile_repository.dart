import '../data/user_profile_dao.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({required UserProfileDao dao}) : _dao = dao;

  final UserProfileDao _dao;

  Future<UserProfile?> getProfile() {
    return _dao.getFirstProfile();
  }

  Future<int> saveProfile(UserProfile profile) {
    return _dao.saveProfile(profile);
  }
}
