import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/models/staff_booking.dart';
import 'package:petpal/features/staff_examination/widgets/staff_booking_card.dart';

void main() {
  testWidgets('exposes the important booking details as one tappable card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffBookingCard(
            booking: const StaffBooking(
              id: 9,
              userId: 3,
              petId: 4,
              petName: 'Mít',
              customerName: 'Nguyễn An',
              serviceName: 'Khám tổng quát',
              bookingDate: '2026-06-23',
              startTime: '09:00',
              endTime: '09:30',
              status: 'confirmed',
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Lịch hẹn 09:00 - 09:30 cho Mít, Khám tổng quát, Nguyễn An, Đã xác nhận',
      ),
      findsOneWidget,
    );
  });
}
