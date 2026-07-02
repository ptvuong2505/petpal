import 'package:flutter/foundation.dart';

import '../models/dashboard_summary.dart';
import '../repositories/admin_dashboard_repository.dart';

class AdminDashboardProvider extends ChangeNotifier {
  AdminDashboardProvider({required AdminDashboardRepository repository})
      : _repository = repository;

  final AdminDashboardRepository _repository;

  DashboardSummary? summary;
  bool isLoading = false;

  Future<void> loadSummary() async {
    isLoading = true;
    notifyListeners();

    summary = await _repository.getSummary();

    isLoading = false;
    notifyListeners();
  }
}
