import 'package:flutter/foundation.dart';

import '../models/examination_result.dart';
import '../repositories/staff_examination_repository.dart';

class StaffExaminationProvider extends ChangeNotifier {
  StaffExaminationProvider({required StaffExaminationRepository repository})
    : _repository = repository;

  final StaffExaminationRepository _repository;

  List<ExaminationResult> results = [];
  bool isLoading = false;

  Future<void> loadResults() async {
    isLoading = true;
    notifyListeners();

    results = await _repository.getResults();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createResult(ExaminationResult result) async {
    await _repository.createResult(result);
    await loadResults();
  }
}
