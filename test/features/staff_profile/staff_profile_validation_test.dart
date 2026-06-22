import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_profile/validators/staff_profile_validation.dart';

void main() {
  test('requires specialty and bio after trimming whitespace', () {
    expect(validateSpecialty('  '), 'Vui lòng nhập chuyên khoa.');
    expect(validateBio('\n'), 'Vui lòng nhập giới thiệu chuyên môn.');
    expect(validateSpecialty('Nội khoa'), isNull);
    expect(validateBio('Có kinh nghiệm chăm sóc thú cưng.'), isNull);
  });

  test('limits bio to 500 characters', () {
    expect(validateBio('a' * 500), isNull);
    expect(validateBio('a' * 501), 'Giới thiệu tối đa 500 ký tự.');
  });

  test('allows experience from 0 through 80 only', () {
    expect(validateExperience('0'), isNull);
    expect(validateExperience('80'), isNull);
    expect(validateExperience('-1'), 'Số năm kinh nghiệm phải từ 0 đến 80.');
    expect(validateExperience('81'), 'Số năm kinh nghiệm phải từ 0 đến 80.');
    expect(
      validateExperience('two'),
      'Vui lòng nhập số năm kinh nghiệm hợp lệ.',
    );
  });

  test('trims and removes blank certificate lines', () {
    expect(cleanedCertificates(' Chứng chỉ A \n\n  Chứng chỉ B  \n '), [
      'Chứng chỉ A',
      'Chứng chỉ B',
    ]);
  });
}
