import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../models/dashboard_summary.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<AdminDashboardProvider>();
      if (provider.summary == null && !provider.isLoading) {
        provider.loadSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final summary = provider.summary ?? DashboardSummary.empty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        height: 32 / 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tổng quan hoạt động hiện tại của PetPal.',
                      style: TextStyle(
                        color: AppColors.subText,
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SummaryGrid(summary: summary),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Booking theo ngày',
                      child: _BookingChart(items: summary.dailyBookings),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 720;
                        final children = [
                          _SectionCard(
                            title: 'Recent Bookings',
                            trailing: _TextAction(
                              label: 'View All',
                              routeName: AppRoutes.timeSlotManagement,
                            ),
                            child: _RecentBookingsList(
                              bookings: summary.recentBookings,
                            ),
                          ),
                          _SectionCard(
                            title: 'Quản lý ca trực',
                            trailing: _TextAction(
                              label: 'Quản lý',
                              routeName: AppRoutes.adminShiftCalendar,
                            ),
                            child: const Text(
                              'Xem danh sách ca trực và quản lý nhân viên.',
                            ),
                          ),
                          _SectionCard(
                            title: 'Recent Reviews',
                            trailing: _TextAction(
                              label: 'Manage',
                              routeName: AppRoutes.reviewList,
                            ),
                            child: _RecentReviewsList(
                              reviews: summary.recentReviews,
                            ),
                          ),
                        ];

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 16),
                              Expanded(child: children[1]),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            children[0],
                            const SizedBox(height: 16),
                            children[1],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        label: 'Tổng Pet',
        value: summary.totalPets.toString(),
        icon: Icons.pets,
        trend: 'Từ database',
        trendColor: AppColors.primary,
      ),
      _StatItem(
        label: 'Tổng Booking',
        value: summary.totalBookings.toString(),
        icon: Icons.calendar_month,
        trend: 'Từ database',
        trendColor: AppColors.primary,
      ),
      _StatItem(
        label: 'Tổng Review',
        value: summary.totalReviews.toString(),
        icon: Icons.rate_review,
        trend: 'Từ database',
        trendColor: AppColors.primary,
      ),
      _StatItem(
        label: 'Tác vụ',
        value: summary.openTasks.toString(),
        icon: Icons.dashboard_customize,
        trend: 'Cần xử lý',
        trendColor: AppColors.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 4 ? 1.45 : 1.25,
          ),
          itemBuilder: (context, index) => _StatCard(item: items[index]),
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.trend,
    required this.trendColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color trendColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 14, color: item.trendColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.trend,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.trendColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BookingChart extends StatelessWidget {
  const _BookingChart({required this.items});

  final List<DailyBookingCount> items;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(
      0,
      (max, item) => item.count > max ? item.count : max,
    );

    return Column(
      children: [
        Container(
          height: 190,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: _heightFactor(items[index].count, maxCount),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: index == 4
                            ? AppColors.primary
                            : AppColors.primaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        boxShadow: index == 4
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                if (index != items.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: Text(
                  _weekdayLabel(items[index].date),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isToday(items[index].date)
                        ? AppColors.primary
                        : AppColors.subText,
                    fontSize: 12,
                    fontWeight: _isToday(items[index].date)
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  double _heightFactor(int count, int maxCount) {
    if (maxCount == 0) {
      return 0.08;
    }
    return (count / maxCount).clamp(0.08, 1.0).toDouble();
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _weekdayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      default:
        return 'CN';
    }
  }
}

class _RecentBookingsList extends StatelessWidget {
  const _RecentBookingsList({required this.bookings});

  final List<RecentBooking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const _EmptyDashboardMessage(message: 'Chưa có booking nào.');
    }

    return Column(
      children: [
        for (var index = 0; index < bookings.length; index++) ...[
          _BookingItem(
            icon: _serviceIcon(bookings[index].serviceName),
            title:
                '${bookings[index].serviceName} - ${bookings[index].petName}',
            subtitle: _bookingSubtitle(bookings[index]),
            status: _statusLabel(bookings[index].status),
            statusColor: _statusColor(bookings[index].status),
          ),
          if (index != bookings.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  IconData _serviceIcon(String serviceName) {
    final value = serviceName.toLowerCase();
    if (value.contains('health') || value.contains('khám')) {
      return Icons.medical_services;
    }
    if (value.contains('vaccin') || value.contains('tiêm')) {
      return Icons.vaccines;
    }
    if (value.contains('hotel') || value.contains('lưu trú')) {
      return Icons.home_work;
    }
    if (value.contains('dental') || value.contains('răng')) {
      return Icons.health_and_safety;
    }
    return Icons.content_cut;
  }

  String _bookingSubtitle(RecentBooking booking) {
    final date = _formatDate(booking.bookingDate);
    final time = booking.startTime;
    if (time == null || time.isEmpty) {
      return date;
    }
    return '$date, $time';
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) {
      return value.isEmpty ? 'Chưa có ngày' : value;
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.primaryContainer;
      case 'completed':
        return AppColors.secondaryContainer;
      case 'cancelled':
        return AppColors.errorContainer;
      case 'pending':
      default:
        return AppColors.tertiaryContainer;
    }
  }
}

class _RecentReviewsList extends StatelessWidget {
  const _RecentReviewsList({required this.reviews});

  final List<RecentReview> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const _EmptyDashboardMessage(message: 'Chưa có review nào.');
    }

    return Column(
      children: [
        for (var index = 0; index < reviews.length; index++) ...[
          _ReviewItem(
            name: reviews[index].customerName,
            time: _relativeTime(reviews[index].createdAt),
            rating: reviews[index].rating,
            comment: reviews[index].comment,
          ),
          if (index != reviews.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _relativeTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _EmptyDashboardMessage extends StatelessWidget {
  const _EmptyDashboardMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.subText, fontSize: 13),
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  const _BookingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.name,
    required this.time,
    required this.rating,
    required this.comment,
  });

  final String name;
  final String time;
  final int rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var index = 0; index < 5; index++)
                          Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFF59E0B),
                            size: 14,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.subText,
              fontSize: 13,
              height: 18 / 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.routeName});

  final String label;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => NavigationService.goTo(context, routeName),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
