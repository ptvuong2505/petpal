import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/validators/examination_result_validation.dart';

void main() {
  test('requires non-whitespace symptom, diagnosis, and treatment', () {
    expect(
      validateRequiredText('   ', 'Vui lòng nhập triệu chứng.'),
      'Vui lòng nhập triệu chứng.',
    );
    expect(
      validateRequiredText('\n', 'Vui lòng nhập chẩn đoán.'),
      'Vui lòng nhập chẩn đoán.',
    );
    expect(
      validateRequiredText('\t', 'Vui lòng nhập hướng điều trị.'),
      'Vui lòng nhập hướng điều trị.',
    );
    expect(validateRequiredText('Đau bụng', 'x'), isNull);
  });

  test('allows no next visit or a date from today onward', () {
    final today = DateTime(2026, 6, 23);
    expect(validateNextVisitDate('', now: today), isNull);
    expect(validateNextVisitDate('2026-06-23', now: today), isNull);
    expect(validateNextVisitDate('2026-06-24', now: today), isNull);
  });

  test('rejects a next visit date in the past or invalid format', () {
    final today = DateTime(2026, 6, 23);
    expect(
      validateNextVisitDate('2026-06-22', now: today),
      'Ngày tái khám không được trong quá khứ.',
    );
    expect(
      validateNextVisitDate('23/06/2026', now: today),
      'Ngày tái khám không hợp lệ.',
    );
  });
}
