import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/admin_shift_dao.dart';
import '../../staff_schedule/constants/shift_constants.dart';

class AdminAssignShiftPage extends StatefulWidget {
  const AdminAssignShiftPage({super.key});

  @override
  State<AdminAssignShiftPage> createState() => _AdminAssignShiftPageState();
}

class _AdminAssignShiftPageState extends State<AdminAssignShiftPage> {
  final _formKey = GlobalKey<FormState>();
  final _dao = AdminShiftDao();

  List<Map<String, Object?>> _allStaff = [];
  int? _selectedStaffId;
  DateTime _selectedDate = DateTime.now();
  ShiftType _selectedShift = ShiftConstants.morningShift;
  bool _loading = false;
  bool _hasConflict = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadStaff() async {
    final staff = await _dao.getAllStaff();
    if (!mounted) return;
    setState(() => _allStaff = staff);
  }

  Future<void> _checkConflict() async {
    if (_selectedStaffId == null) return;

    final hasConflict = await _dao.checkConflict(
      staffId: _selectedStaffId!,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      startTime: _selectedShift.startTime,
      endTime: _selectedShift.endTime,
    );

    if (!mounted) return;
    setState(() => _hasConflict = hasConflict);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    await _checkConflict();
    if (!mounted) return;

    if (_hasConflict) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xung đột lịch'),
          content: const Text(
            'Staff đã có ca trong khung giờ này. Vẫn muốn xếp ca?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Vẫn xếp ca'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _loading = true);
    try {
      await _dao.assignShift(
        staffId: _selectedStaffId!,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        startTime: _selectedShift.startTime,
        endTime: _selectedShift.endTime,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xếp ca thành công')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xếp ca mới')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _selectedStaffId,
              decoration: const InputDecoration(
                labelText: 'Chọn nhân viên',
                border: OutlineInputBorder(),
              ),
              items: _allStaff.map((staff) {
                return DropdownMenuItem(
                  value: staff['id'] as int,
                  child: Text(staff['full_name'] as String),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedStaffId = value;
                        _hasConflict = false;
                      });
                    },
              validator: (value) =>
                  value == null ? 'Vui lòng chọn nhân viên' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Ngày'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _loading ? null : _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ShiftType>(
              value: _selectedShift,
              decoration: const InputDecoration(
                labelText: 'Ca trực',
                border: OutlineInputBorder(),
              ),
              items: ShiftConstants.allShifts.map((shift) {
                return DropdownMenuItem(
                  value: shift,
                  child: Text(shift.displayText),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedShift = value;
                          _hasConflict = false;
                        });
                      }
                    },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Xếp ca'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _hasConflict = false;
      });
    }
  }
}
