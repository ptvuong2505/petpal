import 'package:flutter/foundation.dart';

import '../models/examination_result.dart';
import '../models/staff_booking.dart';
import '../repositories/staff_examination_repository.dart';

class StaffExaminationProvider extends ChangeNotifier {
  StaffExaminationProvider({required StaffExaminationRepository repository})
    : _repository = repository;

  final StaffExaminationRepository _repository;

  List<StaffBooking> bookings = [];
  List<ExaminationResult> results = [];
  List<ExaminationResult> petHealthRecords = [];
  StaffBooking? selectedBooking;
  ExaminationResult? selectedResult;
  ExaminationResult? resultDetail;
  bool isLoading = false;
  bool isLoadingResultDetail = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadBookings({String? date, String? status}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bookings = await _repository.getBookings(date: date, status: status);
    } catch (error) {
      bookings = [];
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookingDetail(int bookingId) async {
    isLoading = true;
    errorMessage = null;
    selectedBooking = null;
    selectedResult = null;
    petHealthRecords = [];
    notifyListeners();

    try {
      final booking = await _repository.getBookingDetail(bookingId);
      if (booking == null) {
        throw StateError('Booking not found');
      }

      selectedBooking = booking;
      petHealthRecords = await _repository.getPetHealthRecords(booking.petId);
      selectedResult = await _repository.getResultByBooking(bookingId);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResults() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      results = await _repository.getResults();
    } catch (error) {
      results = [];
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResultDetail(int resultId) async {
    isLoadingResultDetail = true;
    errorMessage = null;
    resultDetail = null;
    notifyListeners();
    try {
      resultDetail = await _repository.getResultById(resultId);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoadingResultDetail = false;
      notifyListeners();
    }
  }

  Future<int?> createExaminationResult(ExaminationResult result) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _repository.createResult(result);
    } catch (error) {
      errorMessage = _readableError(error);
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String _readableError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }
}
