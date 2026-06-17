import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({required BookingRepository repository})
    : _repository = repository;

  final BookingRepository _repository;

  List<Booking> bookings = [];
  bool isLoading = false;

  // Booking flow selections
  final Set<int> _selectedServiceIds = {};
  int? _selectedPetId;
  int? _selectedTimeSlotId;

  Set<int> get selectedServiceIds => _selectedServiceIds;
  int? get selectedPetId => _selectedPetId;
  int? get selectedTimeSlotId => _selectedTimeSlotId;

  void toggleService(int id) {
    if (_selectedServiceIds.contains(id)) {
      _selectedServiceIds.remove(id);
    } else {
      _selectedServiceIds.add(id);
    }
    notifyListeners();
  }

  void selectPet(int petId) {
    _selectedPetId = petId;
    notifyListeners();
  }

  void selectTimeSlot(int timeSlotId) {
    _selectedTimeSlotId = timeSlotId;
    notifyListeners();
  }

  void resetBookingFlow() {
    _selectedServiceIds.clear();
    _selectedPetId = null;
    _selectedTimeSlotId = null;
    notifyListeners();
  }

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
