import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

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

  String _day(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final monday = _date.subtract(Duration(days: _date.weekday - 1));
    final items = await _dao.schedule(
      id,
      _day(monday),
      _day(monday.add(const Duration(days: 6))),
    );
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _request() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final date = TextEditingController(text: _day(_date));
    final start = TextEditingController(text: '08:00');
    final end = TextEditingController(text: '12:00');
    final note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng ký ca trực'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: date,
                decoration: const InputDecoration(
                  labelText: 'Ngày (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: start,
                decoration: const InputDecoration(labelText: 'Bắt đầu'),
              ),
              TextField(
                controller: end,
                decoration: const InputDecoration(labelText: 'Kết thúc'),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _dao.requestShift(
                  staffId: id,
                  date: date.text,
                  start: start.text,
                  end: end.text,
                  note: note.text,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                await _load();
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$error')));
                }
              }
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _date = _date.subtract(const Duration(days: 7));
                  _loading = true;
                });
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
              onPressed: () {
                setState(() {
                  _date = _date.add(const Duration(days: 7));
                  _loading = true;
                });
                _load();
              },
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              onPressed: _request,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const Wrap(
          spacing: 12,
          children: [
            Chip(avatar: Icon(Icons.work, size: 16), label: Text('Ca trực')),
            Chip(avatar: Icon(Icons.pets, size: 16), label: Text('Lịch hẹn')),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? const Center(child: Text('Không có lịch trong tuần này.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final shift = item['event_type'] == 'shift';
                    return Card(
                      child: ListTile(
                        leading: Icon(shift ? Icons.work_outline : Icons.pets),
                        title: Text('${item['title']}'),
                        subtitle: Text(
                          '${item['event_date']} • ${item['start_time'] ?? '--:--'}-${item['end_time'] ?? '--:--'}',
                        ),
                        trailing: Chip(label: Text('${item['status']}')),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
