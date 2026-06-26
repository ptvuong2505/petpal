import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calendar_shift_item.dart';
import 'shift_status_indicator.dart';

enum CalendarViewMode { week, month }

class ShiftCalendarView extends StatelessWidget {
  const ShiftCalendarView({
    required this.viewMode,
    required this.focusedDate,
    required this.shifts,
    required this.onShiftTap,
    super.key,
  });

  final CalendarViewMode viewMode;
  final DateTime focusedDate;
  final List<CalendarShiftItem> shifts;
  final ValueChanged<CalendarShiftItem> onShiftTap;

  @override
  Widget build(BuildContext context) {
    return viewMode == CalendarViewMode.week
        ? _WeekView(
            focusedDate: focusedDate,
            shifts: shifts,
            onShiftTap: onShiftTap,
          )
        : _MonthView(
            focusedDate: focusedDate,
            shifts: shifts,
            onShiftTap: onShiftTap,
          );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.focusedDate,
    required this.shifts,
    required this.onShiftTap,
  });

  final DateTime focusedDate;
  final List<CalendarShiftItem> shifts;
  final ValueChanged<CalendarShiftItem> onShiftTap;

  @override
  Widget build(BuildContext context) {
    final monday = focusedDate.subtract(
      Duration(days: focusedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: days.map((day) {
        final dayShifts = shifts
            .where((s) => s.shiftDate == _dateKey(day))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                _dayLabel(day),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (dayShifts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Không có ca trực',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...dayShifts.map(
                (shift) =>
                    _ShiftCard(shift: shift, onTap: () => onShiftTap(shift)),
              ),
          ],
        );
      }).toList(),
    );
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _dayLabel(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return '${weekdays[date.weekday - 1]}, ${DateFormat('dd/MM').format(date)}';
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.focusedDate,
    required this.shifts,
    required this.onShiftTap,
  });

  final DateTime focusedDate;
  final List<CalendarShiftItem> shifts;
  final ValueChanged<CalendarShiftItem> onShiftTap;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Month view - Coming soon'));
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shift, required this.onTap});

  final CalendarShiftItem shift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.staffName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shift.startTime} - ${shift.endTime}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ShiftStatusIndicator(
                status: shift.status,
                requestType: shift.requestType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
