import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffExaminationProvider>().loadBookings(date: _today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();

    if (provider.isLoading && provider.bookings.isEmpty) {
      return const AppLoading();
    }
    if (provider.errorMessage != null && provider.bookings.isEmpty) {
      return _DashboardError(
        message: provider.errorMessage!,
        onRetry: () => provider.loadBookings(date: _today),
      );
    }

    final bookings = provider.bookings;
    final waiting = bookings
        .where(
          (booking) =>
              booking.status == 'pending' || booking.status == 'confirmed',
        )
        .length;
    final completed = bookings
        .where((booking) => booking.status == 'completed')
        .length;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () => provider.loadBookings(date: _today),
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
                        label: 'Hôm nay',
                        value: bookings.length,
                        icon: Icons.calendar_today,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        label: 'Cần xử lý',
                        value: waiting,
                        icon: Icons.pending_actions,
                        color: Colors.orange,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lịch hẹn hôm nay',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => NavigationService.goTo(
                    context,
                    AppRoutes.staffBookingList,
                  ),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (bookings.isEmpty)
              const SizedBox(
                height: 180,
                child: AppEmptyState(message: 'Hôm nay chưa có lịch hẹn.'),
              )
            else
              ...bookings
                  .take(5)
                  .map(
                    (booking) => StaffBookingCard(
                      booking: booking,
                      compact: true,
                      onTap: () => _openBooking(context, booking),
                    ),
                  ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Xem tất cả lịch hẹn',
              icon: Icons.list_alt,
              onPressed: () =>
                  NavigationService.goTo(context, AppRoutes.staffBookingList),
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

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          AppButton(label: 'Thử lại', onPressed: onRetry),
        ],
      ),
    );
  }
}
