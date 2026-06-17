import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({required UserProfileRepository repository})
    : _repository = repository;

  final UserProfileRepository _repository;

  UserProfile? profile;
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    profile = await _repository.getProfile();

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile value) async {
    await _repository.saveProfile(value);
    profile = value;
    notifyListeners();
  }
}
