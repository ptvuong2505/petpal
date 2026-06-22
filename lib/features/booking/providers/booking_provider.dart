// file: lib/features/booking/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import '../data/booking_dao.dart';
import '../models/booking.dart'; //
import '../repositories/booking_repository.dart'; //
import '../../../core/database/app_database.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({
    required BookingRepository repository,
    BookingDao? bookingDao,
  }) : _repository = repository,
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
  static const int slotIntervalMinutes =
      30; // Khoảng cách mỗi ô lịch là 30 phút

  // Danh sách mốc giờ mặc định (đồng bộ với UI)
  static const List<Map<String, dynamic>> defaultTimeSlots = [
    {'id': 1, 'start_time': '08:30'},
    {'id': 2, 'start_time': '09:00'},
    {'id': 3, 'start_time': '09:30'},
    {'id': 4, 'start_time': '10:00'},
    {'id': 5, 'start_time': '10:30'},
    {'id': 6, 'start_time': '11:00'},
    {'id': 7, 'start_time': '11:30'},
    {'id': 8, 'start_time': '12:00'},
    {'id': 9, 'start_time': '12:30'},
    {'id': 10, 'start_time': '13:00'},
    {'id': 11, 'start_time': '13:30'},
    {'id': 12, 'start_time': '14:00'},
    {'id': 13, 'start_time': '14:30'},
    {'id': 14, 'start_time': '15:00'},
    {'id': 15, 'start_time': '15:30'},
    {'id': 16, 'start_time': '16:00'},
    {'id': 17, 'start_time': '16:30'},
    {'id': 18, 'start_time': '17:00'},
    {'id': 19, 'start_time': '17:30'},
    {'id': 20, 'start_time': '18:00'},
    {'id': 21, 'start_time': '18:30'},
    {'id': 22, 'start_time': '19:00'},
    {'id': 23, 'start_time': '19:30'},
    {'id': 24, 'start_time': '20:00'},
    {'id': 25, 'start_time': '20:30'},
  ];

  // Getters
  Set<int> get selectedServiceIds => _selectedServiceIds; //
  int? get selectedPetId => _selectedPetId; //
  int? get selectedTimeSlotId => _selectedTimeSlotId; //
  int? get selectedStaffId => _selectedStaffId;
  List<int> get busyStaffIds => _busyStaffIds;
  List<int> get busySlotIds => _busySlotIds;
  String get currentDateStr => _currentDateStr;

  // Tìm start_time từ ID
  String? _getStartTimeFromId(int id) {
    try {
      final slot = defaultTimeSlots.firstWhere((s) => s['id'] == id);
      return slot['start_time'] as String;
    } catch (_) {
      return null;
    }
  }

  // Lấy tổng thời lượng (phút) để tính toán khung giờ và khóa lịch nhân viên
  // Loại trừ các dịch vụ lưu trú (duration >= 1440) vì chúng không chiếm dụng nhân viên theo Slot
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
        int duration = (result.first['duration_minutes'] as int? ?? 30);
        // Nếu dịch vụ dưới 1440 phút (dưới 1 ngày) thì mới tính vào thời lượng Slot hẹn
        if (duration < 1440) {
          totalDuration += duration;
        }
      }
    }
    // Nếu chỉ chọn dịch vụ lưu trú, mặc định Slot hẹn tối thiểu là 30 phút để có khung giờ bắt đầu
    return totalDuration == 0 ? 30 : totalDuration;
  }

  // Hàm Helper phân tích và tính toán chuỗi giờ liên tiếp bị chiếm dụng dựa trên tổng duration
  List<String> _calculateOccupiedTimeStrings(
    String startHourStr,
    int totalDurationMinutes,
  ) {
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
      final nextTimeStr =
          '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
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
  // Cần kiểm tra xem trong khoảng thời gian (start_time + duration), nhân viên có bận slot nào không
  void selectTimeSlot(int timeSlotId) async {
    _selectedTimeSlotId = timeSlotId;

    if (_currentDateStr.isNotEmpty) {
      final startTime = _getStartTimeFromId(timeSlotId);
      if (startTime != null) {
        final totalDuration = await calculateTotalSelectedDuration();
        final requiredTimes = _calculateOccupiedTimeStrings(
          startTime,
          totalDuration,
        );

        _busyStaffIds = await _bookingDao.getBusyStaffIds(
          date: _currentDateStr,
          startTimes: requiredTimes,
        );

        if (_selectedStaffId != null &&
            _busyStaffIds.contains(_selectedStaffId)) {
          _selectedStaffId = null;
        }
      }
    }
    notifyListeners();
  }

  // CHIỀU 2: Chọn Nhân viên trước -> Khóa chuỗi Giờ bận (Thời gian bắt đầu + Tổng duration)
  void selectStaff(int? staffId) async {
    _selectedStaffId = staffId;

    if (staffId != null && _currentDateStr.isNotEmpty) {
      // 1. Lấy danh sách các mốc giờ nhân viên bận thực tế trong DB
      final List<String> databaseBusyTimes = await _bookingDao
          .getBusyStartTimesForStaff(date: _currentDateStr, staffId: staffId);

      // 2. Tính tổng thời lượng của giỏ hàng dịch vụ hiện tại
      final int totalDuration = await calculateTotalSelectedDuration();

      List<int> calculationBusySlotIds = [];

      // Duyệt qua tất cả các slot mặc định để kiểm tra xem nếu bắt đầu từ slot đó có bị trùng lịch không
      for (final slot in defaultTimeSlots) {
        final int slotId = slot['id'] as int;
        final String startTime = slot['start_time'] as String;

        // Tính toán chuỗi mốc thời gian chiếm dụng nếu chọn bắt đầu từ slot này
        final List<String> requiredTimes = _calculateOccupiedTimeStrings(
          startTime,
          totalDuration,
        );

        // Nếu bất kỳ mốc thời gian nào trong chuỗi dự kiến va chạm với lịch bận sẵn có trong DB -> Khóa slot bắt đầu này
        bool isConflict = requiredTimes.any(
          (time) => databaseBusyTimes.contains(time),
        );
        if (isConflict) {
          calculationBusySlotIds.add(slotId);
        }
      }

      _busySlotIds = calculationBusySlotIds;
      if (_selectedTimeSlotId != null &&
          _busySlotIds.contains(_selectedTimeSlotId)) {
        _selectedTimeSlotId = null;
      }
    } else {
      _busySlotIds.clear();
    }
    notifyListeners();
  }

  void toggleService(int id) {
    //
    if (_selectedServiceIds.contains(id)) {
      //
      _selectedServiceIds.remove(id); //
    } else {
      //
      _selectedServiceIds.add(id); //
    } //
    notifyListeners(); //
  } //

  void selectPet(int petId) {
    //
    _selectedPetId = petId; //
    notifyListeners(); //
  } //

  void resetBookingFlow() {
    //
    _selectedServiceIds.clear(); //
    _selectedPetId = null; //
    _selectedTimeSlotId = null; //
    _selectedStaffId = null;
    _busyStaffIds.clear();
    _busySlotIds.clear();
    _currentDateStr = '';
    notifyListeners(); //
  } //

  Future<void> loadBookings() async {
    //
    isLoading = true; //
    notifyListeners(); //
    bookings = await _repository.getBookings(); //
    isLoading = false; //
    notifyListeners(); //
  } //

  Future<void> createBooking(Booking booking) async {
    //
    await _repository.createBooking(booking); //
    await loadBookings(); //
  } //
}
