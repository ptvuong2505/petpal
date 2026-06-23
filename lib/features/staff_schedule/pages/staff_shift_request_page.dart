import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_content.dart';
import '../validators/staff_shift_validation.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffShiftRequestPage extends StatefulWidget {
  const StaffShiftRequestPage({super.key});

  @override
  State<StaffShiftRequestPage> createState() => _StaffShiftRequestPageState();
}

class _StaffShiftRequestPageState extends State<StaffShiftRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _dao = StaffPortalDao();
  final _date = TextEditingController();
  final _start = TextEditingController(text: '08:00');
  final _end = TextEditingController(text: '12:00');
  final _note = TextEditingController();
  bool _submitting = false;
  String? _submitError;

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
    if (_submitting || !_formKey.currentState!.validate()) return;

    final staffId = context.read<AuthProvider>().currentUser?.id;
    if (staffId == null) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      await _dao.requestShift(
        staffId: staffId,
        date: _date.text.trim(),
        start: _start.text.trim(),
        end: _end.text.trim(),
        note: _note.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu đăng ký ca trực.')),
      );
      NavigationService.goTo(context, AppRoutes.staffSchedule);
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitError =
              'Không thể gửi yêu cầu. Vui lòng kiểm tra thời gian đã chọn.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi yêu cầu. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = DateTime.tryParse(_date.text.trim());
    final initialDate = current == null || current.isBefore(today)
        ? today
        : current;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _date.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    });
    _formKey.currentState?.validate();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.trim().split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length == 2 ? int.tryParse(parts.last) : null;
    final selected = await showTimePicker(
      context: context,
      initialTime: hour == null || minute == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: hour, minute: minute),
    );
    if (selected == null || !mounted) return;
    setState(() {
      controller.text = formatShiftTime(
        hour: selected.hour,
        minute: selected.minute,
      );
    });
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      'Đăng ký ca trực',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Nhập thời gian bạn có thể làm việc.'),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _date,
                      enabled: !_submitting,
                      readOnly: true,
                      onTap: _submitting ? null : _pickDate,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateShiftDate,
                      decoration: const InputDecoration(
                        labelText: 'Ngày (YYYY-MM-DD)',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _start,
                      enabled: !_submitting,
                      readOnly: true,
                      onTap: _submitting ? null : () => _pickTime(_start),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateShiftTime,
                      decoration: const InputDecoration(
                        labelText: 'Bắt đầu (HH:mm)',
                        suffixIcon: Icon(Icons.schedule_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _end,
                      enabled: !_submitting,
                      readOnly: true,
                      onTap: _submitting ? null : () => _pickTime(_end),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          validateShiftTime(value) ??
                          validateShiftTimeRange(
                            start: _start.text,
                            end: value ?? '',
                          ),
                      decoration: const InputDecoration(
                        labelText: 'Kết thúc (HH:mm)',
                        suffixIcon: Icon(Icons.schedule_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffInfoSection(
                      title: 'Khoảng thời gian đã chọn',
                      icon: Icons.schedule_outlined,
                      children: [
                        StaffInfoRow(label: 'Ngày', value: _date.text),
                        StaffInfoRow(
                          label: 'Thời gian',
                          value: '${_start.text} – ${_end.text}',
                        ),
                      ],
                    ),
                    if (_submitError != null) ...[
                      Text(
                        _submitError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _note,
                      enabled: !_submitting,
                      maxLines: 3,
                      maxLength: 500,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateShiftNote,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              StaffStickyActionBar(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_submitting ? 'Đang gửi...' : 'Gửi yêu cầu'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
