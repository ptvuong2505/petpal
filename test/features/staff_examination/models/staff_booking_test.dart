import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/models/staff_booking.dart';

void main() {
  test('maps joined booking data for staff screens', () {
    final booking = StaffBooking.fromMap({
      'id': 4,
      'user_id': 2,
      'pet_id': 8,
      'service_name': 'Health Check',
      'booking_date': '2026-06-12',
      'status': 'confirmed',
      'booking_note': 'Pet is tired',
      'total_price': 100000,
      'customer_name': 'Nguyen An',
      'customer_email': 'an@example.com',
      'customer_phone': '0901',
      'pet_name': 'Milo',
      'pet_species': 'Dog',
      'pet_breed': 'Poodle',
      'pet_gender': 'Male',
      'pet_birth_date': '2022-05-10',
      'pet_weight': 5.6,
      'pet_note': 'Friendly',
      'start_time': '09:00',
      'end_time': '10:00',
      'result_id': 21,
    });

    expect(booking.id, 4);
    expect(booking.customerName, 'Nguyen An');
    expect(booking.petName, 'Milo');
    expect(booking.startTime, '09:00');
    expect(booking.hasResult, isTrue);
    expect(booking.resultId, 21);
  });
}
