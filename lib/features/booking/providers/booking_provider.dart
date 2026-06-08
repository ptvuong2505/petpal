import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({required BookingRepository repository})
    : _repository = repository;

  final BookingRepository _repository;

  List<Booking> bookings = [];
  bool isLoading = false;

  Future<void> loadBookings() async {
    isLoading = true;
    notifyListeners();

    bookings = await _repository.getBookings();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(Booking booking) async {
    await _repository.createBooking(booking);
    await loadBookings();
  }
}
