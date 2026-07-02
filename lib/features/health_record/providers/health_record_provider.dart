import 'package:flutter/foundation.dart';

import '../models/health_record.dart';
import '../repositories/health_record_repository.dart';

class HealthRecordProvider extends ChangeNotifier {
  HealthRecordProvider({required HealthRecordRepository repository})
      : _repository = repository;

  final HealthRecordRepository _repository;

  List<HealthRecord> records = [];
  bool isLoading = false;

  Future<void> loadRecords() async {
    isLoading = true;
    notifyListeners();

    records = await _repository.getRecords();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecordsByPetId(int petId) async {
    isLoading = true;
    notifyListeners();

    try {
      records = await _repository.getRecordsByPetId(petId);
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(HealthRecord record) async {
    await _repository.addRecord(record);
    await loadRecordsByPetId(record.petId);
  }
}
