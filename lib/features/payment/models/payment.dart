class Payment {
  const Payment({
    this.id,
    required this.bookingId,
    required this.orderCode,
    this.paymentLinkId,
    required this.amount,
    required this.description,
    this.qrCode,
    this.checkoutUrl,
    this.status = 'PENDING',
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.lastCheckedAt,
    this.lastError,
  });

  final int? id;
  final int bookingId;
  final int orderCode;
  final String? paymentLinkId;
  final int amount;
  final String description;
  final String? qrCode;
  final String? checkoutUrl;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? paidAt;
  final String? lastCheckedAt;
  final String? lastError;

  bool get isPaid => status == 'PAID';
  bool get isTerminal =>
      status == 'PAID' || status == 'CANCELLED' || status == 'EXPIRED';
  bool get hasPaymentLink =>
      paymentLinkId != null && qrCode != null && checkoutUrl != null;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'order_code': orderCode,
      'payment_link_id': paymentLinkId,
      'amount': amount,
      'description': description,
      'qr_code': qrCode,
      'checkout_url': checkoutUrl,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'paid_at': paidAt,
      'last_checked_at': lastCheckedAt,
      'last_error': lastError,
    };
  }

  factory Payment.fromMap(Map<String, Object?> map) {
    return Payment(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int,
      orderCode: map['order_code'] as int,
      paymentLinkId: map['payment_link_id'] as String?,
      amount: map['amount'] as int,
      description: map['description'] as String,
      qrCode: map['qr_code'] as String?,
      checkoutUrl: map['checkout_url'] as String?,
      status: (map['status'] as String? ?? 'PENDING').toUpperCase(),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      paidAt: map['paid_at'] as String?,
      lastCheckedAt: map['last_checked_at'] as String?,
      lastError: map['last_error'] as String?,
    );
  }

  Payment copyWith({
    int? id,
    String? paymentLinkId,
    String? qrCode,
    String? checkoutUrl,
    String? status,
    String? updatedAt,
    String? paidAt,
    String? lastCheckedAt,
    String? lastError,
    bool clearLastError = false,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId,
      orderCode: orderCode,
      paymentLinkId: paymentLinkId ?? this.paymentLinkId,
      amount: amount,
      description: description,
      qrCode: qrCode ?? this.qrCode,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }
}
