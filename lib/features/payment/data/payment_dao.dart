import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/payment.dart';

typedef DatabaseProvider = Future<Database> Function();

class PaymentDao {
  PaymentDao({DatabaseProvider? databaseProvider})
    : _databaseProvider =
          databaseProvider ?? (() => AppDatabase.instance.database);

  final DatabaseProvider _databaseProvider;

  Future<int> getBookingAmount(int bookingId) async {
    final db = await _databaseProvider();
    final rows = await db.query(
      'bookings',
      columns: ['total_price'],
      where: 'id = ?',
      whereArgs: [bookingId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Không tìm thấy booking #$bookingId.');
    }
    return ((rows.first['total_price'] as num?) ?? 0).round();
  }

  Future<Payment?> findByBookingId(int bookingId) async {
    final db = await _databaseProvider();
    final rows = await db.query(
      'payments',
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      limit: 1,
    );
    return rows.isEmpty ? null : Payment.fromMap(rows.first);
  }

  Future<Payment> ensurePayment({
    required int bookingId,
    required int orderCode,
    required int amount,
    required String description,
    required DateTime now,
  }) async {
    final existing = await findByBookingId(bookingId);
    if (existing != null) return existing;

    final db = await _databaseProvider();
    final timestamp = now.toIso8601String();
    final id = await db.insert('payments', {
      'booking_id': bookingId,
      'order_code': orderCode,
      'amount': amount,
      'description': description,
      'status': 'PENDING',
      'created_at': timestamp,
      'updated_at': timestamp,
    });
    return (await findById(id))!;
  }

  Future<Payment?> findById(int paymentId) async {
    final db = await _databaseProvider();
    final rows = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [paymentId],
      limit: 1,
    );
    return rows.isEmpty ? null : Payment.fromMap(rows.first);
  }

  Future<Payment> updatePaymentLink({
    required int paymentId,
    required String paymentLinkId,
    required String qrCode,
    required String checkoutUrl,
    required String status,
    required DateTime now,
  }) async {
    final db = await _databaseProvider();
    await db.update(
      'payments',
      {
        'payment_link_id': paymentLinkId,
        'qr_code': qrCode,
        'checkout_url': checkoutUrl,
        'status': status.toUpperCase(),
        'updated_at': now.toIso8601String(),
        'last_checked_at': now.toIso8601String(),
        'last_error': null,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    return (await findById(paymentId))!;
  }

  Future<Payment> updateStatus({
    required int paymentId,
    required String status,
    required DateTime now,
  }) async {
    final normalized = status.toUpperCase();
    final db = await _databaseProvider();
    await db.update(
      'payments',
      {
        'status': normalized,
        'updated_at': now.toIso8601String(),
        'last_checked_at': now.toIso8601String(),
        'paid_at': normalized == 'PAID' ? now.toIso8601String() : null,
        'last_error': null,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    return (await findById(paymentId))!;
  }

  Future<Payment> recordError({
    required int paymentId,
    required Object error,
    required DateTime now,
  }) async {
    final db = await _databaseProvider();
    await db.update(
      'payments',
      {
        'last_error': error.toString(),
        'updated_at': now.toIso8601String(),
        'last_checked_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    return (await findById(paymentId))!;
  }
}
