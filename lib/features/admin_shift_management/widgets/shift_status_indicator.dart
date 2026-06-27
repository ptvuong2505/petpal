import 'package:flutter/material.dart';

class ShiftStatusInfo {
  const ShiftStatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  static ShiftStatusInfo fromStatus(String status, String requestType) {
    if (status == 'pending') {
      return const ShiftStatusInfo(
        label: 'Chờ duyệt',
        color: Colors.orange,
        icon: Icons.hourglass_top_outlined,
      );
    }
    if (status == 'approved') {
      if (requestType == 'admin_assign') {
        return const ShiftStatusInfo(
          label: 'Admin xếp',
          color: Colors.blue,
          icon: Icons.admin_panel_settings_outlined,
        );
      }
      return const ShiftStatusInfo(
        label: 'Đã duyệt',
        color: Colors.green,
        icon: Icons.task_alt,
      );
    }
    if (status == 'rejected') {
      return const ShiftStatusInfo(
        label: 'Từ chối',
        color: Colors.red,
        icon: Icons.cancel_outlined,
      );
    }
    return const ShiftStatusInfo(
      label: 'Không rõ',
      color: Colors.grey,
      icon: Icons.help_outline,
    );
  }
}

class ShiftStatusIndicator extends StatelessWidget {
  const ShiftStatusIndicator({
    required this.status,
    required this.requestType,
    super.key,
  });

  final String status;
  final String requestType;

  @override
  Widget build(BuildContext context) {
    final info = ShiftStatusInfo.fromStatus(status, requestType);
    final foreground = Color.lerp(info.color, Colors.black, 0.35)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
