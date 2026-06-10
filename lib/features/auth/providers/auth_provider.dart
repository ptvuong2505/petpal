import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  User? currentUser;
  bool isLoading = false;
  bool isCheckingLogin = true;

  bool get isLoggedIn => currentUser != null;

  String? get currentRole => currentUser?.role;

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('userId');

      if (userId == null) {
        currentUser = null;
        return;
      }

      currentUser = User(
        id: userId,
        fullName: prefs.getString('fullName') ?? '',
        email: prefs.getString('email') ?? '',
        password: prefs.getString('password'),
        phone: prefs.getString('phone'),
        address: prefs.getString('address'),
        role: prefs.getString('role') ?? 'user',
      );
    } catch (e) {
      debugPrint('checkLoginStatus error: $e');
      currentUser = null;
    } finally {
      isCheckingLogin = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.login(email: email, password: password);

      if (user == null) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }

      currentUser = user;
      await _saveLoginSession(user);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(User user) async {
    isLoading = true;
    notifyListeners();

    await _repository.register(user);

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('fullName');
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('phone');
    await prefs.remove('address');
    await prefs.remove('role');

    currentUser = null;
    notifyListeners();
  }

  Future<void> _saveLoginSession(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('userId', user.id!);
    await prefs.setString('fullName', user.fullName);
    await prefs.setString('email', user.email);
    await prefs.setString('password', user.password ?? '');
    await prefs.setString('phone', user.phone ?? '');
    await prefs.setString('address', user.address ?? '');
    await prefs.setString('role', user.role);
  }
}
