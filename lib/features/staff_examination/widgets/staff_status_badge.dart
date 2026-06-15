import 'package:flutter/material.dart';

class StaffStatusBadge extends StatelessWidget {
  const StaffStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'confirmed' => Colors.blue,
      'completed' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.orange,
    };
    final label = switch (status) {
      'confirmed' => 'Đã xác nhận',
      'completed' => 'Hoàn thành',
      'cancelled' => 'Đã hủy',
      _ => 'Đang chờ',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
