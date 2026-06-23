import 'package:flutter/material.dart';

import '../models/staff_booking.dart';
import 'staff_booking_status.dart';
import 'staff_status_badge.dart';

class StaffBookingCard extends StatelessWidget {
  const StaffBookingCard({
    required this.booking,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final StaffBooking booking;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final timeRange = _timeRange();
    final status = StaffBookingStatus.fromRaw(booking.status);
    final semanticsLabel =
        'Lịch hẹn $timeRange cho ${booking.petName}, ${booking.serviceName}, '
        '${booking.customerName}, ${status.label}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          timeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StaffStatusBadge(status: booking.status),
                    ],
                  ),
                  if (booking.bookingDate?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        booking.bookingDate!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.pets_outlined,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.petName.isEmpty
                                  ? 'Không rõ thú cưng'
                                  : booking.petName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.serviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!compact &&
                      booking.customerPhone?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      booking.customerPhone!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeRange() {
    if (booking.startTime == null || booking.startTime!.isEmpty) {
      return 'Chưa có giờ hẹn';
    }
    if (booking.endTime == null || booking.endTime!.isEmpty) {
      return booking.startTime!;
    }
    return '${booking.startTime} - ${booking.endTime}';
  }
}
