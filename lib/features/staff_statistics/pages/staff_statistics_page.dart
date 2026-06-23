import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';

class StaffStatisticsPage extends StatefulWidget {
  const StaffStatisticsPage({super.key});

  @override
  State<StaffStatisticsPage> createState() => _StaffStatisticsPageState();
}

class _StaffStatisticsPageState extends State<StaffStatisticsPage> {
  final _dao = StaffPortalDao();
  final DateTime _anchor = DateTime.now();
  Map<String, Object?>? _data;
  bool _month = false;
  bool _loading = true;
  String? _errorMessage;

  String _day(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final start = _month
        ? DateTime(_anchor.year, _anchor.month, 1)
        : _anchor.subtract(Duration(days: _anchor.weekday - 1));
    final end = _month
        ? DateTime(_anchor.year, _anchor.month + 1, 0)
        : start.add(const Duration(days: 6));
    try {
      final data = await _dao.statistics(id, _day(start), _day(end));
      if (mounted) setState(() => _data = data);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Không thể tải thống kê.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _load,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading && _data == null) {
      return const StaffLoadingState(skeleton: true);
    }
    if (_errorMessage != null && _data == null) {
      return StaffErrorState(message: _errorMessage!, onRetry: _load);
    }
    final data = _data;
    if (data == null) {
      return StaffEmptyState(
        icon: Icons.bar_chart_outlined,
        message: 'Chưa có dữ liệu thống kê.',
        onRetry: _load,
      );
    }

    final assigned = _asInt(data['assigned']);
    final completed = _asInt(data['completed']);
    final examinations = _asInt(data['examinations']);
    final ratingCount = _asInt(data['rating_count']);
    final rating = _asDouble(data['average_rating']);
    final rate = assigned == 0 ? 0.0 : completed / assigned;
    final feedback = _feedback(data['feedback']);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Tuần')),
                ButtonSegment(value: true, label: Text('Tháng')),
              ],
              selected: {_month},
              onSelectionChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _month = value.first);
                      _load();
                    },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 360 ? 2 : 3;
                const gap = 8.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    _StatCard(
                      label: 'Được giao',
                      value: '$assigned',
                      icon: Icons.assignment_outlined,
                      width: width,
                    ),
                    _StatCard(
                      label: 'Hoàn thành',
                      value: '$completed',
                      icon: Icons.task_alt,
                      width: width,
                    ),
                    _StatCard(
                      label: 'Tỷ lệ',
                      value: '${(rate * 100).toStringAsFixed(0)}%',
                      icon: Icons.percent,
                      width: width,
                    ),
                    _StatCard(
                      label: 'Ca khám',
                      value: '$examinations',
                      icon: Icons.medical_services_outlined,
                      width: width,
                    ),
                    _StatCard(
                      label: 'Đánh giá',
                      value: rating == null || ratingCount == 0
                          ? 'Chưa có'
                          : rating.toStringAsFixed(1),
                      icon: Icons.star_outline,
                      width: width,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tỷ lệ hoàn thành ${(rate * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: rate, minHeight: 12),
            ),
            const SizedBox(height: 24),
            Text(
              'Phản hồi gần đây',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (feedback.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.star_border),
                      SizedBox(width: 12),
                      Expanded(child: Text('Chưa có đánh giá.')),
                    ],
                  ),
                ),
              )
            else
              ...feedback.map(
                (item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${item['rating'] ?? 0}★'),
                    ),
                    title: Text('${item['pet_name'] ?? 'Thú cưng'}'),
                    subtitle: Text('${item['comment'] ?? 'Không có nhận xét'}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _asInt(Object? value) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    return value is num ? value.toDouble() : double.tryParse('$value');
  }

  List<Map<String, Object?>> _feedback(Object? value) {
    return value is List
        ? value.whereType<Map<String, Object?>>().toList()
        : [];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
