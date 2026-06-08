import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  User? currentUser;
  bool isLoading = false;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    currentUser = await _repository.login(email: email, password: password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(User user) async {
    isLoading = true;
    notifyListeners();

    await _repository.register(user);

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
