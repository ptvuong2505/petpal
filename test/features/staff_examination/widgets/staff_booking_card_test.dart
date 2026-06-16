import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/models/staff_booking.dart';
import 'package:petpal/features/staff_examination/widgets/staff_booking_card.dart';
import 'package:petpal/features/staff_examination/widgets/staff_status_badge.dart';

void main() {
  testWidgets('booking card renders joined data and handles tap', (
    tester,
  ) async {
    var tapped = false;
    const booking = StaffBooking(
      id: 1,
      userId: 2,
      petId: 3,
      serviceName: 'Health Check',
      bookingDate: '2026-06-12',
      startTime: '09:00',
      status: 'confirmed',
      customerName: 'Nguyen An',
      customerPhone: '0901',
      petName: 'Milo',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffBookingCard(booking: booking, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Milo'), findsOneWidget);
    expect(find.text('Health Check • Nguyen An'), findsOneWidget);
    expect(find.text('2026-06-12 • 09:00'), findsOneWidget);
    expect(find.text('Đã xác nhận'), findsOneWidget);

    await tester.tap(find.byType(StaffBookingCard));
    expect(tapped, isTrue);
  });

  testWidgets('status badge labels completed bookings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StaffStatusBadge(status: 'completed')),
      ),
    );

    expect(find.text('Hoàn thành'), findsOneWidget);
  });
}
