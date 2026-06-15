import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/models/examination_result.dart';

void main() {
  test('maps examination input to health_records columns', () {
    const result = ExaminationResult(
      bookingId: 5,
      petId: 3,
      staffId: 9,
      title: 'Health check for Milo',
      symptom: 'Low appetite',
      diagnosis: 'Mild indigestion',
      treatment: 'Monitor meals',
      medicine: 'PetBio',
      note: 'Return in one week',
      recordDate: '2026-06-12',
    );

    expect(result.toMap(), {
      'id': null,
      'pet_id': 3,
      'booking_id': 5,
      'staff_id': 9,
      'title': 'Health check for Milo',
      'symptom': 'Low appetite',
      'diagnosis': 'Mild indigestion',
      'treatment': 'Monitor meals',
      'medicine': 'PetBio',
      'note': 'Return in one week',
      'record_date': '2026-06-12',
      'next_visit_date': null,
      'created_at': null,
      'updated_at': null,
    });
  });

  test('reads staff name from a joined health record row', () {
    final result = ExaminationResult.fromMap({
      'id': 1,
      'pet_id': 3,
      'title': 'Previous visit',
      'staff_name': 'Le Minh Staff',
    });

    expect(result.petId, 3);
    expect(result.title, 'Previous visit');
    expect(result.staffName, 'Le Minh Staff');
  });
}
