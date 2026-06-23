import 'package:flutter/material.dart';

@immutable
class StaffBookingStatus {
  const StaffBookingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  static StaffBookingStatus fromRaw(String? raw) {
    switch (raw) {
      case 'pending':
        return const StaffBookingStatus(
          label: 'Đang chờ',
          color: Colors.orange,
          icon: Icons.schedule_outlined,
        );
      case 'confirmed':
        return const StaffBookingStatus(
          label: 'Đã xác nhận',
          color: Colors.blue,
          icon: Icons.event_available_outlined,
        );
      case 'completed':
        return const StaffBookingStatus(
          label: 'Hoàn thành',
          color: Colors.green,
          icon: Icons.task_alt,
        );
      case 'cancelled':
        return const StaffBookingStatus(
          label: 'Đã hủy',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        );
      default:
        return const StaffBookingStatus(
          label: 'Không xác định',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is StaffBookingStatus &&
        other.label == label &&
        other.color == color &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(label, color, icon);
}
