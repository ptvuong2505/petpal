// file: lib/features/booking/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import '../data/booking_dao.dart';
import '../models/booking.dart'; //
import '../repositories/booking_repository.dart'; //
import '../../../core/database/app_database.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({required BookingRepository repository, BookingDao? bookingDao})
      : _repository = repository,
        _bookingDao = bookingDao ?? BookingDao();

  final BookingRepository _repository; //
  final BookingDao _bookingDao;

  List<Booking> bookings = []; //
  bool isLoading = false; //

  // Trạng thái luồng Đặt lịch
  final Set<int> _selectedServiceIds = {}; //
  int? _selectedPetId; //
  int? _selectedTimeSlotId; //
  int? _selectedStaffId;

  // Trạng thái đồng bộ tương tác 2 chiều & thời gian liên tiếp
  List<Map<String, Object?>> allStaff = [];
  List<int> _busyStaffIds = [];
  List<int> _busySlotIds = [];
  String _currentDateStr = '';
  static const int slotIntervalMinutes = 30; // Khoảng cách mỗi ô lịch là 30 phút

  // Getters
  Set<int> get selectedServiceIds => _selectedServiceIds; //
  int? get selectedPetId => _selectedPetId; //
  int? get selectedTimeSlotId => _selectedTimeSlotId; //
  int? get selectedStaffId => _selectedStaffId;
  List<int> get busyStaffIds => _busyStaffIds;
  List<int> get busySlotIds => _busySlotIds;

  // Lấy tổng thời lượng (phút) của tất cả các dịch vụ đã chọn
  Future<int> calculateTotalSelectedDuration() async {
    if (_selectedServiceIds.isEmpty) return 0;
    final db = await AppDatabase.instance.database;
    int totalDuration = 0;

    for (final serviceId in _selectedServiceIds) {
      final List<Map<String, Object?>> result = await db.query(
        'services',
        columns: ['duration_minutes'],
        where: 'id = ?',
        whereArgs: [serviceId],
      );
      if (result.isNotEmpty) {
        totalDuration += (result.first['duration_minutes'] as int? ?? 30);
      }
    }
    return totalDuration;
  }

  // Hàm Helper phân tích và tính toán chuỗi giờ liên tiếp bị chiếm dụng dựa trên tổng duration
  List<String> _calculateOccupiedTimeStrings(String startHourStr, int totalDurationMinutes) {
    List<String> occupiedTimes = [startHourStr];
    final parts = startHourStr.split(':');
    if (parts.length < 2) return occupiedTimes;

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    int slotsNeeded = (totalDurationMinutes / slotIntervalMinutes).ceil();

    int currentHour = hour;
    int currentMinute = minute;

    for (int i = 1; i < slotsNeeded; i++) {
      currentMinute += slotIntervalMinutes;
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
      final nextTimeStr = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
      occupiedTimes.add(nextTimeStr);
    }
    return occupiedTimes;
  }

  // Khởi tạo/Cập nhật ngày đặt lịch
  void updateBookingDate(String dateStr) async {
    _currentDateStr = dateStr;
    _selectedTimeSlotId = null;
    _selectedStaffId = null;
    _busyStaffIds.clear();
    _busySlotIds.clear();

    allStaff = await _bookingDao.getAllStaff();
    notifyListeners();
  }

  // CHIỀU 1: Chọn Khung giờ trước -> Lọc khóa Nhân viên bận
  void selectTimeSlot(int timeSlotId) async { //
    _selectedTimeSlotId = timeSlotId; //

    if (_currentDateStr.isNotEmpty) {
      _busyStaffIds = await _bookingDao.getBusyStaffIds(
        date: _currentDateStr,
        timeSlotId: timeSlotId,
      );
      if (_selectedStaffId != null && _busyStaffIds.contains(_selectedStaffId)) {
        _selectedStaffId = null;
      }
    }
    notifyListeners(); //
  }

  // CHIỀU 2: Chọn Nhân viên trước -> Khóa chuỗi Giờ bận (Thời gian bắt đầu + Tổng duration)
  void selectStaff(int? staffId) async {
    _selectedStaffId = staffId;

    if (staffId != null && _currentDateStr.isNotEmpty) {
      // 1. Lấy danh sách các mốc giờ nhân viên bận thực tế trong DB
      final List<Map<String, Object?>> baseBusySlots = await _bookingDao.getBusySlotsDetailsForStaff(
        date: _currentDateStr,
        staffId: staffId,
      );
      final Set<String> databaseBusyTimes = baseBusySlots
          .map((slot) => slot['start_time'] as String? ?? '')
          .where((time) => time.isNotEmpty)
          .toSet();

      // 2. Tính tổng thời lượng của giỏ hàng dịch vụ hiện tại
      final int totalDuration = await calculateTotalSelectedDuration();

      // 3. Lấy toàn bộ khung giờ đang hoạt động của hệ thống để chạy vòng lặp kiểm tra giả định
      final db = await AppDatabase.instance.database;
      final List<Map<String, Object?>> allDaySlots = await db.query(
        'time_slots',
        where: 'status = ?',
        whereArgs: ['available'],
      );

      List<int> calculationBusySlotIds = [];

      for (final slot in allDaySlots) {
        final int slotId = slot['id'] as int;
        final String startTime = slot['start_time'] as String;

        // Tính toán chuỗi mốc thời gian chiếm dụng nếu chọn bắt đầu từ slot này
        final List<String> requiredTimes = _calculateOccupiedTimeStrings(startTime, totalDuration);

        // Nếu bất kỳ mốc thời gian nào trong chuỗi dự kiến va chạm với lịch bận sẵn có trong DB -> Khóa slot bắt đầu này
        bool isConflict = requiredTimes.any((time) => databaseBusyTimes.contains(time));
        if (isConflict) {
          calculationBusySlotIds.add(slotId);
        }
      }

      _busySlotIds = calculationBusySlotIds;
      if (_selectedTimeSlotId != null && _busySlotIds.contains(_selectedTimeSlotId)) {
        _selectedTimeSlotId = null;
      }
    } else {
      _busySlotIds.clear();
    }
    notifyListeners();
  }

  void toggleService(int id) { //
    if (_selectedServiceIds.contains(id)) { //
      _selectedServiceIds.remove(id); //
    } else { //
      _selectedServiceIds.add(id); //
    } //
    notifyListeners(); //
  } //

  void selectPet(int petId) { //
    _selectedPetId = petId; //
    notifyListeners(); //
  } //

  void resetBookingFlow() { //
    _selectedServiceIds.clear(); //
    _selectedPetId = null; //
    _selectedTimeSlotId = null; //
    _selectedStaffId = null;
    _busyStaffIds.clear();
    _busySlotIds.clear();
    _currentDateStr = '';
    notifyListeners(); //
  } //

  Future<void> loadBookings() async { //
    isLoading = true; //
    notifyListeners(); //
    bookings = await _repository.getBookings(); //
    isLoading = false; //
    notifyListeners(); //
  } //

  Future<void> createBooking(Booking booking) async { //
    await _repository.createBooking(booking); //
    await loadBookings(); //
  } //
}