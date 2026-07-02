import '../data/payment_dao.dart';
import '../models/payment.dart';
import '../services/payos_client.dart';

abstract interface class PaymentRepositoryContract {
  Future<Payment> initializePayment(int bookingId);
  Future<Payment> refreshPayment(Payment payment);
}

class PaymentRepository implements PaymentRepositoryContract {
  PaymentRepository({
    required PaymentDao dao,
    required PayOsClient payOsClient,
    int Function()? orderCodeFactory,
    DateTime Function()? now,
  })  : _dao = dao,
        _payOsClient = payOsClient,
        _orderCodeFactory =
            orderCodeFactory ?? (() => DateTime.now().millisecondsSinceEpoch),
        _now = now ?? DateTime.now;

  final PaymentDao _dao;
  final PayOsClient _payOsClient;
  final int Function() _orderCodeFactory;
  final DateTime Function() _now;

  @override
  Future<Payment> initializePayment(int bookingId) async {
    final amount = await _dao.getBookingAmount(bookingId);
    final payment = await _dao.ensurePayment(
      bookingId: bookingId,
      orderCode: _orderCodeFactory(),
      amount: amount,
      description: _descriptionFor(bookingId),
      now: _now(),
    );
    if (payment.isTerminal || payment.hasPaymentLink) return payment;
    return _createRemoteLink(payment);
  }

  @override
  Future<Payment> refreshPayment(Payment payment) async {
    if (payment.isTerminal) return payment;
    if (!payment.hasPaymentLink) return _createRemoteLink(payment);

    try {
      final result = await _payOsClient.getPaymentInformation(
        payment.orderCode,
      );
      return _dao.updateStatus(
        paymentId: payment.id!,
        status: result.status,
        now: _now(),
      );
    } catch (error) {
      return _dao.recordError(
        paymentId: payment.id!,
        error: error,
        now: _now(),
      );
    }
  }

  Future<Payment> _createRemoteLink(Payment payment) async {
    try {
      final result = await _payOsClient.createPaymentLink(
        orderCode: payment.orderCode,
        amount: payment.amount,
        description: payment.description,
      );
      final paymentLinkId = result.paymentLinkId;
      final qrCode = result.qrCode;
      final checkoutUrl = result.checkoutUrl;
      if (paymentLinkId == null || qrCode == null || checkoutUrl == null) {
        throw const PayOsException(
          'payOS không trả về đủ QR code và checkout URL.',
        );
      }
      return _dao.updatePaymentLink(
        paymentId: payment.id!,
        paymentLinkId: paymentLinkId,
        qrCode: qrCode,
        checkoutUrl: checkoutUrl,
        status: result.status,
        now: _now(),
      );
    } catch (error) {
      return _dao.recordError(
        paymentId: payment.id!,
        error: error,
        now: _now(),
      );
    }
  }

  String _descriptionFor(int bookingId) {
    final value = 'PP$bookingId';
    return value.length <= 9 ? value : value.substring(value.length - 9);
  }
}
