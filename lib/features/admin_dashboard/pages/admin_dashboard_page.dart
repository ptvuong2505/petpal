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
    final summary =
        provider.summary ??
        const DashboardSummary(totalPets: 0, totalBookings: 0, totalReviews: 0);

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
                    const _SectionCard(
                      title: 'Booking theo ngày',
                      child: _BookingChart(),
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
                            child: Column(
                              children: const [
                                _BookingItem(
                                  icon: Icons.content_cut,
                                  title: 'Grooming - Milo',
                                  subtitle: 'Hôm nay, 08:00',
                                  status: 'Confirmed',
                                  statusColor: AppColors.primaryContainer,
                                ),
                                SizedBox(height: 8),
                                _BookingItem(
                                  icon: Icons.medical_services,
                                  title: 'Health Check - Mimi',
                                  subtitle: 'Hôm nay, 09:00',
                                  status: 'Completed',
                                  statusColor: AppColors.secondaryContainer,
                                ),
                                SizedBox(height: 8),
                                _BookingItem(
                                  icon: Icons.vaccines,
                                  title: 'Vaccination - Lucky',
                                  subtitle: 'Hôm nay, 10:00',
                                  status: 'Pending',
                                  statusColor: AppColors.tertiaryContainer,
                                ),
                              ],
                            ),
                          ),
                          _SectionCard(
                            title: 'Recent Reviews',
                            trailing: _TextAction(
                              label: 'Manage',
                              routeName: AppRoutes.reviewList,
                            ),
                            child: Column(
                              children: const [
                                _ReviewItem(
                                  name: 'Sarah J.',
                                  time: '2h ago',
                                  rating: 5,
                                  comment:
                                      'Dịch vụ rất tốt, nhân viên chăm sóc pet kỹ và đúng giờ.',
                                ),
                                SizedBox(height: 8),
                                _ReviewItem(
                                  name: 'Mike T.',
                                  time: '1d ago',
                                  rating: 4,
                                  comment:
                                      'Grooming ổn, chỉ hơi trễ lịch bắt đầu một chút.',
                                ),
                              ],
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
        trend: '+5%',
        trendColor: AppColors.primary,
      ),
      _StatItem(
        label: 'Tổng Booking',
        value: summary.totalBookings.toString(),
        icon: Icons.calendar_month,
        trend: '+12%',
        trendColor: AppColors.primary,
      ),
      _StatItem(
        label: 'Tổng Review',
        value: summary.totalReviews.toString(),
        icon: Icons.rate_review,
        trend: '+4%',
        trendColor: AppColors.primary,
      ),
      const _StatItem(
        label: 'Tác vụ',
        value: '3',
        icon: Icons.dashboard_customize,
        trend: 'Admin',
        trendColor: AppColors.textMuted,
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
        border: Border.all(color: const Color(0xFFE4E2E2)),
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
        border: Border.all(color: const Color(0xFFE4E2E2)),
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
  const _BookingChart();

  static const _bars = [0.40, 0.60, 0.45, 0.80, 0.95, 0.70, 0.50];
  static const _labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 190,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < _bars.length; index++) ...[
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: _bars[index],
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
                if (index != _bars.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < _labels.length; index++)
              Expanded(
                child: Text(
                  _labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: index == 4 ? AppColors.primary : AppColors.subText,
                    fontSize: 12,
                    fontWeight: index == 4 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
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
        color: const Color(0xFFF5F3F3),
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
        border: Border.all(color: const Color(0xFFE4E2E2)),
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
