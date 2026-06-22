import 'package:flutter/material.dart';

import 'staff_booking_status.dart';

class StaffStatusBadge extends StatelessWidget {
  const StaffStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bookingStatus = StaffBookingStatus.fromRaw(status);
    final color = bookingStatus.color;
    final foreground = Color.lerp(color, Colors.black, 0.35)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(bookingStatus.icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            bookingStatus.label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
