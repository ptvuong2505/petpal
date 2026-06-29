import '../data/booking_dao.dart';
import '../models/booking.dart';

class BookingRepository {
  BookingRepository({required BookingDao dao}) : _dao = dao;

  final BookingDao _dao;

  Future<List<Booking>> getBookings() {
    return _dao.getBookings();
  }

  Future<List<Map<String, Object?>>> getBookingsByUserId(int userId) {
    return _dao.getBookingsByUserId(userId);
  }

  Future<int> createBooking(Booking booking) {
    return _dao.insertBooking(booking);
  }
}
