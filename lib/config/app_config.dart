class AppConfig {
  static const bool useLocalDatabase = true;
  static const String environmentName = 'local';

  static const String payOsClientId = String.fromEnvironment('PAYOS_CLIENT_ID');
  static const String payOsApiKey = String.fromEnvironment('PAYOS_API_KEY');
  static const String payOsChecksumKey = String.fromEnvironment(
    'PAYOS_CHECKSUM_KEY',
  );
  static const String payOsReturnUrl = String.fromEnvironment(
    'PAYOS_RETURN_URL',
    defaultValue: 'https://payos.vn',
  );
  static const String payOsCancelUrl = String.fromEnvironment(
    'PAYOS_CANCEL_URL',
    defaultValue: 'https://payos.vn',
  );

  static bool get isPayOsConfigured =>
      payOsClientId.isNotEmpty &&
      payOsApiKey.isNotEmpty &&
      payOsChecksumKey.isNotEmpty;
}
