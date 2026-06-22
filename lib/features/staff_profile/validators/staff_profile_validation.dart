String? validateSpecialty(String? value) {
  return value == null || value.trim().isEmpty
      ? 'Vui lòng nhập chuyên khoa.'
      : null;
}

String? validateBio(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập giới thiệu chuyên môn.';
  return text.runes.length > 500 ? 'Giới thiệu tối đa 500 ký tự.' : null;
}

String? validateExperience(String? value) {
  final years = int.tryParse(value?.trim() ?? '');
  if (years == null) return 'Vui lòng nhập số năm kinh nghiệm hợp lệ.';
  return years < 0 || years > 80
      ? 'Số năm kinh nghiệm phải từ 0 đến 80.'
      : null;
}

List<String> cleanedCertificates(String value) {
  return value
      .split('\n')
      .map((certificate) => certificate.trim())
      .where((certificate) => certificate.isNotEmpty)
      .toList();
}
