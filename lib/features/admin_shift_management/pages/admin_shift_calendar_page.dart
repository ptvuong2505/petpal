import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../data/admin_shift_dao.dart';
import '../models/calendar_shift_item.dart';
import '../widgets/shift_bottom_sheet.dart';
import '../widgets/shift_calendar_view.dart';
import '../widgets/staff_filter_chips.dart';

class AdminShiftCalendarPage extends StatefulWidget {
  const AdminShiftCalendarPage({super.key});

  @override
  State<AdminShiftCalendarPage> createState() => _AdminShiftCalendarPageState();
}

class _AdminShiftCalendarPageState extends State<AdminShiftCalendarPage> {
  final _dao = AdminShiftDao();
  CalendarViewMode _viewMode = CalendarViewMode.week;
  DateTime _focusedDate = DateTime.now();
  List<CalendarShiftItem> _shifts = [];
  List<Map<String, Object?>> _allStaff = [];
  List<int>? _selectedStaffIds;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStaff();
    _loadShifts();
  }

  Future<void> _loadAllStaff() async {
    final staff = await _dao.getAllStaff();
    if (!mounted) return;
    setState(() => _allStaff = staff);
  }

  Future<void> _loadShifts() async {
    setState(() => _loading = true);
    try {
      final monday = _focusedDate.subtract(
        Duration(days: _focusedDate.weekday - 1),
      );
      final sunday = monday.add(const Duration(days: 6));

      final shifts = await _dao.getShiftsInRange(
        DateFormat('yyyy-MM-dd').format(monday),
        DateFormat('yyyy-MM-dd').format(sunday),
        _selectedStaffIds,
      );
      if (!mounted) return;
      setState(() => _shifts = shifts);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý ca trực'),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == CalendarViewMode.week
                  ? Icons.calendar_view_month
                  : Icons.calendar_view_week,
            ),
            onPressed: () => setState(
              () => _viewMode = _viewMode == CalendarViewMode.week
                  ? CalendarViewMode.month
                  : CalendarViewMode.week,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                StaffFilterChips(
                  allStaff: _allStaff,
                  selectedStaffIds: _selectedStaffIds,
                  onChanged: (ids) {
                    setState(() => _selectedStaffIds = ids);
                    _loadShifts();
                  },
                ),
                Expanded(
                  child: ShiftCalendarView(
                    viewMode: _viewMode,
                    focusedDate: _focusedDate,
                    shifts: _shifts,
                    onShiftTap: (shift) async {
                      final modified = await showShiftBottomSheet(
                        context,
                        shift,
                      );
                      if (modified == true) _loadShifts();
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          NavigationService.goTo(context, AppRoutes.adminAssignShift);
          // Reload after returning from assign page
          await Future.delayed(const Duration(milliseconds: 500));
          _loadShifts();
        },
      ),
    );
  }
}
