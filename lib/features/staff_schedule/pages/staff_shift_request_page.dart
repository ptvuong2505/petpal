import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffShiftRequestPage extends StatefulWidget {
  const StaffShiftRequestPage({super.key});

  @override
  State<StaffShiftRequestPage> createState() => _StaffShiftRequestPageState();
}

class _StaffShiftRequestPageState extends State<StaffShiftRequestPage> {
  final _dao = StaffPortalDao();
  final _date = TextEditingController();
  final _start = TextEditingController(text: '08:00');
  final _end = TextEditingController(text: '12:00');
  final _note = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final staffId = context.read<AuthProvider>().currentUser?.id;
    if (staffId == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await _dao.requestShift(
        staffId: staffId,
        date: _date.text.trim(),
        start: _start.text.trim(),
        end: _end.text.trim(),
        note: _note.text.trim(),
      );
      if (mounted) {
        NavigationService.goTo(context, AppRoutes.staffSchedule);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _date,
          decoration: const InputDecoration(labelText: 'Ngày (YYYY-MM-DD)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _start,
          decoration: const InputDecoration(labelText: 'Bắt đầu'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _end,
          decoration: const InputDecoration(labelText: 'Kết thúc'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Ghi chú'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting ? 'Đang gửi...' : 'Gửi yêu cầu'),
        ),
      ],
    );
  }
}
