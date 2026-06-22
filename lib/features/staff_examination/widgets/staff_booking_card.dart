import 'package:flutter/material.dart';

import '../models/staff_booking.dart';
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
    final timeRange = booking.startTime == null
        ? null
        : booking.endTime == null
        ? booking.startTime
        : '${booking.startTime} - ${booking.endTime}';
    final time = <String?>[
      booking.bookingDate,
      timeRange,
    ].whereType<String>().join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(
                      booking.petName.isEmpty
                          ? '?'
                          : booking.petName.characters.first.toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.petName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.serviceName} • ${booking.customerName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StaffStatusBadge(status: booking.status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 17),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact && booking.customerPhone?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 17),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.customerPhone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
