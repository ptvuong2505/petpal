import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/widgets/staff_booking_status.dart';

void main() {
  test('maps all booking statuses to Vietnamese labels, colors, and icons', () {
    expect(
      StaffBookingStatus.fromRaw('pending'),
      const StaffBookingStatus(
        label: 'Đang chờ',
        color: Colors.orange,
        icon: Icons.schedule_outlined,
      ),
    );
    expect(StaffBookingStatus.fromRaw('confirmed').label, 'Đã xác nhận');
    expect(StaffBookingStatus.fromRaw('completed').label, 'Hoàn thành');
    expect(StaffBookingStatus.fromRaw('cancelled').label, 'Đã hủy');
  });

  test('uses a safe fallback for an unknown raw status', () {
    expect(StaffBookingStatus.fromRaw('other').label, 'Không xác định');
  });
}
