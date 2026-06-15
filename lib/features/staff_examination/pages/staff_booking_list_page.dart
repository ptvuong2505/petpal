import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }

  @override
  Widget build(BuildContext context) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hôm nay'),
                  selected: _todayOnly,
                  onSelected: (_) {
                    setState(() => _todayOnly = true);
                    _loadBookings();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Tất cả ngày'),
                  selected: !_todayOnly,
                  onSelected: (_) {
                    setState(() => _todayOnly = false);
                    _loadBookings();
                  },
                ),
              ],
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
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildContent(StaffExaminationProvider provider) {
    if (provider.isLoading && provider.bookings.isEmpty) {
      return const AppLoading();
    }
    if (provider.errorMessage != null && provider.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton(label: 'Thử lại', onPressed: _loadBookings),
          ],
        ),
      );
    }
    if (provider.bookings.isEmpty) {
      return const AppEmptyState(message: 'Không có lịch hẹn phù hợp.');
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
