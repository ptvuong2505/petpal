import 'package:flutter/foundation.dart';

import '../models/time_slot.dart';
import '../repositories/time_slot_repository.dart';

class TimeSlotProvider extends ChangeNotifier {
  TimeSlotProvider({required TimeSlotRepository repository})
    : _repository = repository;

  final TimeSlotRepository _repository;

  List<TimeSlot> timeSlots = [];
  bool isLoading = false;

  Future<void> loadTimeSlots() async {
    isLoading = true;
    notifyListeners();

    timeSlots = await _repository.getTimeSlots();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createTimeSlot(TimeSlot timeSlot) async {
    await _repository.createTimeSlot(timeSlot);
    await loadTimeSlots();
  }
}
