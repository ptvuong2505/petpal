import '../data/time_slot_dao.dart';
import '../models/time_slot.dart';

class TimeSlotRepository {
  TimeSlotRepository({required TimeSlotDao dao}) : _dao = dao;

  final TimeSlotDao _dao;

  Future<List<TimeSlot>> getTimeSlots() {
    return _dao.getTimeSlots();
  }

  Future<int> createTimeSlot(TimeSlot timeSlot) {
    return _dao.insertTimeSlot(timeSlot);
  }
}
