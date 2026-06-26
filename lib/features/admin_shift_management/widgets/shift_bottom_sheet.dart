import 'package:flutter/material.dart';

import '../data/admin_shift_dao.dart';
import '../models/calendar_shift_item.dart';
import 'shift_status_indicator.dart';

Future<bool?> showShiftBottomSheet(
  BuildContext context,
  CalendarShiftItem shift,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ShiftBottomSheet(shift: shift),
  );
}

class _ShiftBottomSheet extends StatefulWidget {
  const _ShiftBottomSheet({required this.shift});

  final CalendarShiftItem shift;

  @override
  State<_ShiftBottomSheet> createState() => _ShiftBottomSheetState();
}

class _ShiftBottomSheetState extends State<_ShiftBottomSheet> {
  final _dao = AdminShiftDao();
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await _dao.approveShift(widget.shift.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt ca trực')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    try {
      await _dao.rejectShift(widget.shift.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối ca trực')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.shift.status == 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShiftStatusIndicator(
                status: widget.shift.status,
                requestType: widget.shift.requestType,
              ),
              const SizedBox(height: 16),
              Text(
                widget.shift.staffName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Ngày', value: widget.shift.shiftDate),
              _InfoRow(label: 'Giờ', value: '${widget.shift.startTime} - ${widget.shift.endTime}'),
              _InfoRow(
                label: 'Loại',
                value: widget.shift.requestType == 'register' ? 'Đăng ký' : 'Admin xếp',
              ),
              if (widget.shift.requestNote != null)
                _InfoRow(label: 'Ghi chú staff', value: widget.shift.requestNote!),
              if (widget.shift.adminNote != null)
                _InfoRow(label: 'Ghi chú admin', value: widget.shift.adminNote!),
              const SizedBox(height: 24),
              if (isPending) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _approve,
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Duyệt'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _reject,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Từ chối'),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
