import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_schedule/validators/staff_shift_validation.dart';

void main() {
  final today = DateTime(2026, 6, 23);

  test('rejects a shift date before today', () {
    expect(
      validateShiftDate('2026-06-22', now: today),
      'Không thể đăng ký ca trực cho ngày đã qua.',
    );
  });

  test('accepts today and a future date', () {
    expect(validateShiftDate('2026-06-23', now: today), isNull);
    expect(validateShiftDate('2026-06-24', now: today), isNull);
  });

  test('requires valid 24-hour start and end times', () {
    expect(validateShiftTime('8:00'), 'Giờ phải có dạng HH:mm.');
    expect(validateShiftTime('24:00'), 'Giờ không hợp lệ.');
    expect(validateShiftTime('08:00'), isNull);
  });

  test('requires the start time before the end time', () {
    expect(
      validateShiftTimeRange(start: '12:00', end: '12:00'),
      'Giờ bắt đầu phải trước giờ kết thúc.',
    );
    expect(
      validateShiftTimeRange(start: '13:00', end: '12:00'),
      'Giờ bắt đầu phải trước giờ kết thúc.',
    );
    expect(validateShiftTimeRange(start: '08:00', end: '12:00'), isNull);
  });

  test('limits the note to 500 characters', () {
    expect(validateShiftNote('a' * 500), isNull);
    expect(validateShiftNote('a' * 501), 'Ghi chú tối đa 500 ký tự.');
  });
}
