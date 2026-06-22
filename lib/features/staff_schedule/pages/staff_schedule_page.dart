import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_examination/widgets/staff_booking_status.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';

enum _ScheduleFilter { upcoming, pending, past }

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  final _dao = StaffPortalDao();
  DateTime _date = DateTime.now();
  List<Map<String, Object?>> _items = [];
  bool _loading = true;
  String? _errorMessage;
  _ScheduleFilter _filter = _ScheduleFilter.upcoming;

  String _day(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final monday = _date.subtract(Duration(days: _date.weekday - 1));
      final items = await _dao.schedule(
        id,
        _day(monday),
        _day(monday.add(const Duration(days: 6))),
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Không thể tải lịch làm việc.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _load,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Tuần trước',
                    onPressed: _loading
                        ? null
                        : () {
                            setState(
                              () => _date = _date.subtract(
                                const Duration(days: 7),
                              ),
                            );
                            _load();
                          },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      'Tuần của ${_day(_date)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tuần sau',
                    onPressed: _loading
                        ? null
                        : () {
                            setState(
                              () => _date = _date.add(const Duration(days: 7)),
                            );
                            _load();
                          },
                    icon: const Icon(Icons.chevron_right),
                  ),
                  IconButton(
                    tooltip: 'Đăng ký ca trực',
                    onPressed: _loading
                        ? null
                        : () => NavigationService.goTo(
                            context,
                            AppRoutes.staffShiftRequest,
                          ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: _ScheduleFilter.values
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _filter == filter,
                          label: Text(_filterLabel(filter)),
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _items.isEmpty) return const StaffLoadingState();
    if (_errorMessage != null && _items.isEmpty) {
      return StaffErrorState(message: _errorMessage!, onRetry: _load);
    }

    final items = _items.where(_matchesFilter).toList();
    if (items.isEmpty) {
      return StaffEmptyState(
        icon: Icons.event_note_outlined,
        message: _emptyMessage(),
        onRetry: _load,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) => _ScheduleCard(item: items[index]),
      ),
    );
  }

  bool _matchesFilter(Map<String, Object?> item) {
    switch (_filter) {
      case _ScheduleFilter.pending:
        return item['event_type'] == 'shift' && item['status'] == 'pending';
      case _ScheduleFilter.past:
        return _eventDate(item).isBefore(_today());
      case _ScheduleFilter.upcoming:
        return !_eventDate(item).isBefore(_today()) &&
            !(item['event_type'] == 'shift' && item['status'] == 'pending');
    }
  }

  DateTime _eventDate(Map<String, Object?> item) {
    return DateTime.tryParse('${item['event_date']}') ?? DateTime(1900);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _filterLabel(_ScheduleFilter filter) {
    return switch (filter) {
      _ScheduleFilter.upcoming => 'Sắp tới',
      _ScheduleFilter.pending => 'Đang chờ duyệt',
      _ScheduleFilter.past => 'Đã qua',
    };
  }

  String _emptyMessage() {
    return switch (_filter) {
      _ScheduleFilter.upcoming => 'Không có lịch sắp tới.',
      _ScheduleFilter.pending => 'Không có ca trực đang chờ duyệt.',
      _ScheduleFilter.past => 'Không có lịch đã qua trong tuần này.',
    };
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item});

  final Map<String, Object?> item;

  @override
  Widget build(BuildContext context) {
    final shift = item['event_type'] == 'shift';
    final status = '${item['status'] ?? ''}';
    final statusInfo = _ScheduleStatus.fromRaw(status, isShift: shift);
    final start = item['start_time'] ?? '--:--';
    final end = item['end_time'] ?? '--:--';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Icon(shift ? Icons.work_outline : Icons.pets_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title'] ?? (shift ? 'Ca trực' : 'Lịch hẹn')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${item['event_date']} • $start - $end'),
                  const SizedBox(height: 10),
                  _ScheduleStatusBadge(info: statusInfo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleStatus {
  const _ScheduleStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;

  static _ScheduleStatus fromRaw(String raw, {required bool isShift}) {
    if (isShift) {
      return switch (raw) {
        'pending' => const _ScheduleStatus(
          'Chờ duyệt',
          Colors.orange,
          Icons.hourglass_top_outlined,
        ),
        'approved' => const _ScheduleStatus(
          'Đã duyệt',
          Colors.green,
          Icons.task_alt,
        ),
        'rejected' => const _ScheduleStatus(
          'Từ chối',
          Colors.red,
          Icons.cancel_outlined,
        ),
        _ => const _ScheduleStatus(
          'Chưa xác định',
          Colors.grey,
          Icons.help_outline,
        ),
      };
    }
    final bookingStatus = StaffBookingStatus.fromRaw(raw);
    return _ScheduleStatus(
      bookingStatus.label,
      bookingStatus.color,
      bookingStatus.icon,
    );
  }
}

class _ScheduleStatusBadge extends StatelessWidget {
  const _ScheduleStatusBadge({required this.info});

  final _ScheduleStatus info;

  @override
  Widget build(BuildContext context) {
    final foreground = Color.lerp(info.color, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
