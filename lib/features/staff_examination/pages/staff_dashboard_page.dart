import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_content.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../models/staff_booking.dart';
import '../providers/staff_examination_provider.dart';
import '../widgets/staff_booking_card.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = _dateValue(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _loadBookings,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();

    if (provider.isLoading && provider.bookings.isEmpty) {
      return const StaffLoadingState(skeleton: true);
    }
    if (provider.errorMessage != null && provider.bookings.isEmpty) {
      return StaffErrorState(
        message: provider.errorMessage!,
        onRetry: _loadBookings,
      );
    }

    final bookings = provider.bookings;
    final pending =
        bookings.where((booking) => booking.status == 'pending').length;
    final confirmed =
        bookings.where((booking) => booking.status == 'confirmed').length;
    final completed =
        bookings.where((booking) => booking.status == 'completed').length;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Tổng quan hôm nay',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_displayDate(DateTime.now())),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 260
                    ? 1
                    : constraints.maxWidth < 520
                        ? 2
                        : 3;
                const spacing = 8.0;
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        label: 'Đang chờ',
                        value: pending,
                        icon: Icons.schedule_outlined,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        label: 'Đã xác nhận',
                        value: confirmed,
                        icon: Icons.event_available_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        label: 'Hoàn thành',
                        value: completed,
                        icon: Icons.task_alt,
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            StaffSectionHeader(
              title: 'Lịch hẹn hôm nay',
              action: TextButton(
                onPressed: () =>
                    NavigationService.goTo(context, AppRoutes.staffBookingList),
                child: const Text('Xem tất cả'),
              ),
            ),
            const SizedBox(height: 8),
            if (bookings.isEmpty)
              SizedBox(
                height: 180,
                child: StaffEmptyState(
                  icon: Icons.event_available_outlined,
                  message: 'Hôm nay chưa có lịch hẹn.',
                  onRetry: _loadBookings,
                ),
              )
            else
              ...bookings.take(5).map(
                    (booking) => StaffBookingCard(
                      booking: booking,
                      compact: true,
                      onTap: () => _openBooking(context, booking),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _openBooking(BuildContext context, StaffBooking booking) {
    NavigationService.goTo(
      context,
      AppRoutes.staffBookingDetail,
      queryParameters: {'bookingId': booking.id.toString()},
    );
  }

  Future<void> _loadBookings() {
    return context.read<StaffExaminationProvider>().loadBookings(date: _today);
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _displayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
