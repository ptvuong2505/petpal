import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffStatisticsPage extends StatefulWidget {
  const StaffStatisticsPage({super.key});
  @override
  State<StaffStatisticsPage> createState() => _StaffStatisticsPageState();
}

class _StaffStatisticsPageState extends State<StaffStatisticsPage> {
  final _dao = StaffPortalDao();
  Map<String, Object?>? _data;
  bool _month = false;
  final DateTime _anchor = DateTime.now();
  String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final start = _month
        ? DateTime(_anchor.year, _anchor.month, 1)
        : _anchor.subtract(Duration(days: _anchor.weekday - 1));
    final end = _month
        ? DateTime(_anchor.year, _anchor.month + 1, 0)
        : start.add(const Duration(days: 6));
    final data = await _dao.statistics(id, _day(start), _day(end));
    if (mounted) setState(() => _data = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_data == null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const Center(child: CircularProgressIndicator());
    final assigned = (data['assigned'] as int?) ?? 0;
    final completed = (data['completed'] as int?) ?? 0;
    final rate = assigned == 0 ? 0 : completed * 100 / assigned;
    final feedback = (data['feedback'] as List).cast<Map<String, Object?>>();
    return ListView(
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Tuần')),
            ButtonSegment(value: true, label: Text('Tháng')),
          ],
          selected: {_month},
          onSelectionChanged: (value) {
            setState(() {
              _month = value.first;
              _data = null;
            });
            _load();
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _card('Được giao', '$assigned', Icons.assignment_outlined),
            _card('Hoàn thành', '$completed', Icons.task_alt),
            _card('Tỷ lệ', '${rate.toStringAsFixed(0)}%', Icons.percent),
            _card(
              'Ca khám',
              '${data['examinations'] ?? 0}',
              Icons.medical_services_outlined,
            ),
            _card(
              'Đánh giá',
              (data['average_rating'] as num?)?.toStringAsFixed(1) ?? '0.0',
              Icons.star,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: assigned == 0 ? 0 : completed / assigned,
          minHeight: 12,
        ),
        const SizedBox(height: 20),
        Text('Phản hồi gần đây', style: Theme.of(context).textTheme.titleLarge),
        if (feedback.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Chưa có phản hồi.')),
          ),
        ...feedback.map(
          (item) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${item['rating']}★')),
              title: Text('${item['pet_name'] ?? 'Thú cưng'}'),
              subtitle: Text('${item['comment'] ?? 'Không có nhận xét'}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(String label, String value, IconData icon) => SizedBox(
    width: 150,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
