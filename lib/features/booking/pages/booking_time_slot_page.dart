import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class BookingTimeSlotPage extends StatefulWidget {
  const BookingTimeSlotPage({super.key});

  @override
  State<BookingTimeSlotPage> createState() => _BookingTimeSlotPageState();
}

class _BookingTimeSlotPageState extends State<BookingTimeSlotPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, Object?>> _timeSlots = [];
  int? _selectedSlotId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlotsForDate(_selectedDate);
  }

  String _monthLabel(DateTime d) {
    return '${_monthName(d.month)}, ${d.year}';
  }

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

  Future<void> _loadSlotsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _selectedSlotId = null;
    });

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'time_slots',
      where: 'slot_date = ?',
      whereArgs: [_dateKey(date)],
    );

    setState(() {
      _timeSlots = rows;
      _isLoading = false;
    });
  }

  void _selectSlot(int id) {
    setState(() {
      _selectedSlotId = id;
    });
    context.read<BookingProvider>().selectTimeSlot(id);
  }

  void _continue() {
    if (_selectedSlotId == null) {
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

  List<Map<String, Object?>> _filterSession(String session) {
    // session: morning(<12), afternoon(12-17), evening(>=17)
    return _timeSlots.where((row) {
      final start = (row['start_time'] as String?) ?? '00:00';
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

    // If the slot is not today, it's not in the past
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

  int _availableCount(List<Map<String, Object?>> rows) {
    var sum = 0;
    for (final r in rows) {
      final maxB = (r['max_booking'] as int?) ?? 1;
      final booked = (r['booked_count'] as int?) ?? 0;
      final startTime = (r['start_time'] as String?) ?? '';
      final slotDate = _selectedDate;

      final status = (r['status'] as String?) == 'available';
      final hasSpace = booked < maxB;
      final notPassed = !_isTimePassed(startTime, slotDate);

      if (status && hasSpace && notPassed) {
        sum += (maxB - booked);
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildDateList();

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
                          // Month label
                          Text(
                            _monthLabel(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date selector
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
                                    _loadSlotsForDate(d);
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
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
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

                          // Sessions
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

                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legendItem(AppColors.surface, 'Trống'),
                              const SizedBox(width: 16),
                              _legendItem(AppColors.primary, 'Đã chọn'),
                              const SizedBox(width: 16),
                              _legendItem(AppColors.surface, 'Kín', dim: true),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                            _selectedSlotId == null
                                ? 'Chưa chọn'
                                : _slotSummary(_selectedSlotId!),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionSection(String title, List<Map<String, Object?>> rows) {
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
            final id = (row['id'] as int?) ?? 0;
            final start = (row['start_time'] as String?) ?? '';
            final maxB = (row['max_booking'] as int?) ?? 1;
            final booked = (row['booked_count'] as int?) ?? 0;
            final status = (row['status'] as String?) ?? 'available';
            final isPassed = _isTimePassed(start, _selectedDate);
            final available =
                status == 'available' && booked < maxB && !isPassed;

            final isSelected = _selectedSlotId == id;

            return ElevatedButton(
              onPressed: available ? () => _selectSlot(id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.primary
                    : (available
                          ? AppColors.surface
                          : AppColors.surface.withValues(alpha: 0.9)),
                foregroundColor: isSelected ? Colors.white : AppColors.textDark,
                elevation: isSelected ? 6 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: available
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox.shrink(),
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
    final row = _timeSlots.firstWhere(
      (r) => (r['id'] as int?) == slotId,
      orElse: () => {},
    );
    if (row.isEmpty) return 'Không xác định';
    final time = row['start_time'] as String? ?? '';
    final date = row['slot_date'] as String? ?? _dateKey(_selectedDate);
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

  Widget _legendItem(Color color, String label, {bool dim = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: dim ? const Color(0xFFBFC9C3) : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
