import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../providers/staff_examination_provider.dart';
import '../widgets/staff_booking_card.dart';

class StaffBookingListPage extends StatefulWidget {
  const StaffBookingListPage({super.key});

  @override
  State<StaffBookingListPage> createState() => _StaffBookingListPageState();
}

class _StaffBookingListPageState extends State<StaffBookingListPage> {
  bool _todayOnly = true;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _loadBookings,
      child: Builder(builder: _buildPage),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách lịch hẹn',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Hôm nay')),
                ButtonSegment(value: false, label: Text('Tất cả ngày')),
              ],
              selected: {_todayOnly},
              onSelectionChanged: (selection) {
                final todayOnly = selection.first;
                if (todayOnly == _todayOnly) return;
                setState(() => _todayOnly = todayOnly);
                _loadBookings();
              },
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip('Tất cả', null),
                const SizedBox(width: 8),
                _statusChip('Đang chờ', 'pending'),
                const SizedBox(width: 8),
                _statusChip('Đã xác nhận', 'confirmed'),
                const SizedBox(width: 8),
                _statusChip('Hoàn thành', 'completed'),
                const SizedBox(width: 8),
                _statusChip('Đã hủy', 'cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!provider.isLoading || provider.bookings.isNotEmpty)
            Text(
              '${provider.bookings.length} lịch hẹn',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildContent(StaffExaminationProvider provider) {
    if (provider.isLoading && provider.bookings.isEmpty) {
      return const StaffLoadingState(skeleton: true);
    }
    if (provider.errorMessage != null && provider.bookings.isEmpty) {
      return StaffErrorState(
        message: provider.errorMessage!,
        onRetry: _loadBookings,
      );
    }
    if (provider.bookings.isEmpty) {
      return StaffEmptyState(
        icon: Icons.event_busy_outlined,
        message: 'Không có lịch hẹn phù hợp.',
        onRetry: _loadBookings,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.bookings.length,
        itemBuilder: (context, index) {
          final booking = provider.bookings[index];
          return StaffBookingCard(
            booking: booking,
            onTap: () => NavigationService.goTo(
              context,
              AppRoutes.staffBookingDetail,
              queryParameters: {'bookingId': booking.id.toString()},
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, String? status) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: (_) {
        setState(() => _selectedStatus = status);
        _loadBookings();
      },
    );
  }

  Future<void> _loadBookings() {
    return context.read<StaffExaminationProvider>().loadBookings(
      date: _todayOnly ? _dateValue(DateTime.now()) : null,
      status: _selectedStatus,
    );
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
