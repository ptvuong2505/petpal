// file: lib/features/booking/pages/booking_time_slot_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../providers/booking_provider.dart';

class BookingTimeSlotPage extends StatefulWidget {
  const BookingTimeSlotPage({super.key});

  @override
  State<BookingTimeSlotPage> createState() => _BookingTimeSlotPageState();
}

class _BookingTimeSlotPageState extends State<BookingTimeSlotPage> {
  DateTime _selectedDate = DateTime.now();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ cần cập nhật ngày để đồng bộ danh sách bận của nhân viên qua Provider
      context.read<BookingProvider>().updateBookingDate(
        _dateKey(_selectedDate),
      );
    });
  }

  String _monthLabel(DateTime d) => '${_monthName(d.month)}, ${d.year}';

  String _monthName(int m) {
    const names = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return names[m];
  }

  String _dateKey(DateTime d) => d.toIso8601String().substring(0, 10);

  void _continue() {
    final provider = context.read<BookingProvider>();
    if (provider.selectedTimeSlotId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn khung giờ')));
      return;
    }
    NavigationService.goTo(context, AppRoutes.bookingConfirm);
  }

  List<DateTime> _buildDateList() {
    final today = DateTime.now();
    return List.generate(
      14,
      (i) =>
          DateTime(today.year, today.month, today.day).add(Duration(days: i)),
    );
  }

  // Lọc danh sách mốc giờ mặc định theo buổi dựa trên chuỗi thời gian cứng
  List<Map<String, dynamic>> _filterSession(String session) {
    return BookingProvider.defaultTimeSlots.where((row) {
      final start = row['start_time'] as String;
      final hour = int.tryParse(start.split(':').first) ?? 0;
      if (session == 'morning') return hour < 12;
      if (session == 'afternoon') return hour >= 12 && hour < 17;
      return hour >= 17;
    }).toList();
  }

  bool _isTimePassed(String startTime, DateTime slotDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(slotDate.year, slotDate.month, slotDate.day);
    if (slotDay != today) return false;
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(slotTime);
    } catch (_) {
      return false;
    }
  }

  int _availableCount(List<Map<String, dynamic>> rows) {
    final provider = context.read<BookingProvider>();
    var sum = 0;
    for (final r in rows) {
      final id = r['id'] as int;
      final startTime = r['start_time'] as String;

      final notPassed = !_isTimePassed(startTime, _selectedDate);
      final isSlotDisabledByStaff = provider.busySlotIds.contains(id);

      if (notPassed && !isSlotDisabledByStaff) {
        sum += 1; // Mỗi ô giờ mặc định đại diện cho 1 slot trống khả dụng
      }
    }
    return sum;
  }

  Widget _buildStaffSelector() {
    final provider = context.watch<BookingProvider>();
    if (provider.allStaff.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn Nhân viên / Kỹ thuật viên (Tùy chọn)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.allStaff.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final staff = provider.allStaff[index];
              final staffId = staff['id'] as int;
              final staffName = staff['full_name'] as String;
              final isStaffDisabled = provider.busyStaffIds.contains(staffId);
              final isSelected = provider.selectedStaffId == staffId;

              return ChoiceChip(
                label: Text(staffName),
                selected: isSelected,
                onSelected: isStaffDisabled
                    ? null
                    : (selected) {
                        provider.selectStaff(selected ? staffId : null);
                      },
                selectedColor: AppColors.primaryContainer,
                disabledColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isStaffDisabled
                      ? Colors.grey.shade400
                      : (isSelected ? AppColors.primary : AppColors.textDark),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            },
          ),
        ),
        const Divider(height: 32, thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildDateList();
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          Text(
                            _monthLabel(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 92,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: dates.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final d = dates[index];
                                final isSelected =
                                    _dateKey(d) == _dateKey(_selectedDate);
                                final weekday = [
                                  'CN',
                                  'T2',
                                  'T3',
                                  'T4',
                                  'T5',
                                  'T6',
                                  'T7',
                                ][d.weekday % 7];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = d;
                                    });
                                    context
                                        .read<BookingProvider>()
                                        .updateBookingDate(_dateKey(d));
                                  },
                                  child: Container(
                                    width: 64,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryContainer
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? null
                                          : Border.all(
                                              color: const Color(0xFFBFC9C3),
                                            ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weekday,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${d.day}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildStaffSelector(),

                          _sessionSection(
                            'Buổi sáng',
                            _filterSession('morning'),
                          ),
                          const SizedBox(height: 20),
                          _sessionSection(
                            'Buổi chiều',
                            _filterSession('afternoon'),
                          ),
                          const SizedBox(height: 20),
                          _sessionSection(
                            'Buổi tối',
                            _filterSession('evening'),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời gian đã chọn',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.selectedTimeSlotId == null
                            ? 'Chưa chọn'
                            : _slotSummary(provider.selectedTimeSlotId!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Row(
                      children: const [
                        Text('Tiếp tục'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionSection(String title, List<Map<String, dynamic>> rows) {
    final provider = context.watch<BookingProvider>();
    final avail = _availableCount(rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '$avail chỗ trống',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: rows.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final row = rows[index];
            final id = row['id'] as int;
            final start = row['start_time'] as String;
            final isPassed = _isTimePassed(start, _selectedDate);

            // Loại trừ chéo từ chuỗi giờ bận của nhân viên (Tính từ BookingProvider)
            final isSlotDisabledByStaff = provider.busySlotIds.contains(id);

            final available = !isPassed && !isSlotDisabledByStaff;
            final isSelected = provider.selectedTimeSlotId == id;

            return ElevatedButton(
              onPressed: available ? () => provider.selectTimeSlot(id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.primary
                    : (available ? AppColors.surface : Colors.grey.shade200),
                foregroundColor: isSelected
                    ? Colors.white
                    : (available ? AppColors.textDark : Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) const Icon(Icons.check, size: 16),
                  Text(
                    start,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _slotSummary(int slotId) {
    final row = BookingProvider.defaultTimeSlots.firstWhere(
      (r) => (r['id'] as int) == slotId,
      orElse: () => {},
    );
    if (row.isEmpty) return 'Không xác định';
    final time = row['start_time'] as String;
    final date = _dateKey(_selectedDate);
    return '$time, ${_formatDateLabel(date)}';
  }

  String _formatDateLabel(String dateIso) {
    try {
      final d = DateTime.parse(dateIso);
      return '${d.day} ${_monthName(d.month)} ${d.year}';
    } catch (_) {
      return dateIso;
    }
  }
}
