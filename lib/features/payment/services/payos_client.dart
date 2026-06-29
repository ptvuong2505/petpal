import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PayOsCredentials {
  const PayOsCredentials({
    required this.clientId,
    required this.apiKey,
    required this.checksumKey,
    required this.returnUrl,
    required this.cancelUrl,
  });

  final String clientId;
  final String apiKey;
  final String checksumKey;
  final String returnUrl;
  final String cancelUrl;

  bool get isConfigured =>
      clientId.isNotEmpty && apiKey.isNotEmpty && checksumKey.isNotEmpty;
}

class PayOsPaymentResult {
  const PayOsPaymentResult({
    required this.orderCode,
    required this.status,
    this.paymentLinkId,
    this.qrCode,
    this.checkoutUrl,
  });

  final int orderCode;
  final String status;
  final String? paymentLinkId;
  final String? qrCode;
  final String? checkoutUrl;

  factory PayOsPaymentResult.fromMap(Map<String, Object?> map) {
    return PayOsPaymentResult(
      orderCode: (map['orderCode'] as num).toInt(),
      status: (map['status'] as String? ?? 'PENDING').toUpperCase(),
      paymentLinkId: map['paymentLinkId'] as String?,
      qrCode: map['qrCode'] as String?,
      checkoutUrl: map['checkoutUrl'] as String?,
    );
  }
}

class PayOsException implements Exception {
  const PayOsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PayOsClient {
  PayOsClient({
    required this.credentials,
    http.Client? httpClient,
    Uri? baseUri,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUri = baseUri ?? Uri.parse('https://api-merchant.payos.vn');

  final PayOsCredentials credentials;
  final http.Client _httpClient;
  final Uri _baseUri;

  static String createSignature({
    required int amount,
    required int orderCode,
    required String description,
    required String returnUrl,
    required String cancelUrl,
    required String checksumKey,
  }) {
    final data =
        'amount=$amount&cancelUrl=$cancelUrl&description=$description'
        '&orderCode=$orderCode&returnUrl=$returnUrl';
    return Hmac(
      sha256,
      utf8.encode(checksumKey),
    ).convert(utf8.encode(data)).toString();
  }

  Future<PayOsPaymentResult> createPaymentLink({
    required int orderCode,
    required int amount,
    required String description,
  }) async {
    _ensureConfigured();
    final signature = createSignature(
      amount: amount,
      orderCode: orderCode,
      description: description,
      returnUrl: credentials.returnUrl,
      cancelUrl: credentials.cancelUrl,
      checksumKey: credentials.checksumKey,
    );
    final response = await _httpClient.post(
      _baseUri.resolve('/v2/payment-requests'),
      headers: _headers,
      body: jsonEncode({
        'orderCode': orderCode,
        'amount': amount,
        'description': description,
        'cancelUrl': credentials.cancelUrl,
        'returnUrl': credentials.returnUrl,
        'signature': signature,
      }),
    );
    return _parse(response);
  }

  Future<PayOsPaymentResult> getPaymentInformation(int orderCode) async {
    _ensureConfigured();
    final response = await _httpClient.get(
      _baseUri.resolve('/v2/payment-requests/$orderCode'),
      headers: _headers,
    );
    return _parse(response);
  }

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    'x-client-id': credentials.clientId,
    'x-api-key': credentials.apiKey,
  };

  void _ensureConfigured() {
    if (!credentials.isConfigured) {
      throw const PayOsException(
        'Thiếu PAYOS_CLIENT_ID, PAYOS_API_KEY hoặc PAYOS_CHECKSUM_KEY.',
      );
    }
  }

  PayOsPaymentResult _parse(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw PayOsException(
        'payOS trả về dữ liệu không hợp lệ (${response.statusCode}).',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const PayOsException('payOS trả về dữ liệu không hợp lệ.');
    }
    final code = decoded['code']?.toString();
    final data = decoded['data'];
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        code != '00' ||
        data is! Map<String, Object?>) {
      throw PayOsException(
        decoded['desc']?.toString() ?? 'Không thể kết nối payOS.',
      );
    }
    return PayOsPaymentResult.fromMap(data);
  }
}
