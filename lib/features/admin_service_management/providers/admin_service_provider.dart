import 'package:flutter/material.dart';
import '../../booking/models/service.dart';
import '../repositories/admin_service_repository.dart';

class AdminServiceProvider extends ChangeNotifier {
  AdminServiceProvider({required AdminServiceRepository repository})
      : _repository = repository;

  final AdminServiceRepository _repository;

  List<Service> _services = [];
  List<Service> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await _repository.getAllServices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addService(Service service) async {
    try {
      await _repository.createService(service);
      await loadServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService(Service service) async {
    try {
      await _repository.updateService(service);
      await loadServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      await _repository.deleteService(id);
      await loadServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
