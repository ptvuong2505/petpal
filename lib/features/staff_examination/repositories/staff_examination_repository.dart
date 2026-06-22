import '../data/staff_examination_dao.dart';
import '../models/examination_result.dart';
import '../models/staff_booking.dart';

class StaffExaminationRepository {
  StaffExaminationRepository({required StaffExaminationDao dao}) : _dao = dao;

  final StaffExaminationDao _dao;

  Future<List<StaffBooking>> getBookings({String? date, String? status}) {
    return _dao.getBookings(date: date, status: status);
  }

  Future<StaffBooking?> getBookingDetail(int bookingId) {
    return _dao.getBookingDetail(bookingId);
  }

  Future<List<ExaminationResult>> getResults() {
    return _dao.getResults();
  }

  Future<List<ExaminationResult>> getPetHealthRecords(int petId) {
    return _dao.getPetHealthRecords(petId);
  }

  Future<ExaminationResult?> getResultByBooking(int bookingId) {
    return _dao.getResultByBooking(bookingId);
  }

  Future<ExaminationResult?> getResultById(int resultId) {
    return _dao.getResultById(resultId);
  }

  Future<int> createResult(ExaminationResult result) {
    return _dao.insertResult(result);
  }
}
