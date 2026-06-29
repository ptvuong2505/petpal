import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../models/payment.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({required this.bookingId, super.key});

  final int bookingId;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with WidgetsBindingObserver {
  late PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _paymentProvider.initialize(widget.bookingId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentProvider = context.read<PaymentProvider>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _paymentProvider.onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paymentProvider.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.payment == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final payment = provider.payment;
        if (payment == null) {
          return _buildFatalError(provider);
        }
        return _buildPayment(context, provider, payment);
      },
    );
  }

  Widget _buildFatalError(PaymentProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 52),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'Không thể khởi tạo thanh toán.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => provider.initialize(widget.bookingId),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayment(
    BuildContext context,
    PaymentProvider provider,
    Payment payment,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatusCard(payment: payment),
        const SizedBox(height: 20),
        if (payment.qrCode case final qrCode?)
          Center(
            child: Container(
              key: const ValueKey('payment-qr'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE4E2E2)),
              ),
              child: QrImageView(
                data: qrCode,
                version: QrVersions.auto,
                size: 240,
                semanticsLabel: 'Mã QR thanh toán payOS',
              ),
            ),
          )
        else
          _buildNoQr(provider),
        const SizedBox(height: 20),
        Center(
          child: Text(
            '${_formatAmount(payment.amount)} đ',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Mã đơn: ${payment.orderCode}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mở ứng dụng ngân hàng và quét mã QR. PetPal sẽ tự động kiểm tra trạng thái mỗi 5 giây.',
          textAlign: TextAlign.center,
        ),
        if (provider.errorMessage case final error?) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(error, textAlign: TextAlign.center),
          ),
        ],
        const SizedBox(height: 20),
        if (payment.isPaid)
          FilledButton.icon(
            onPressed: () =>
                NavigationService.goTo(context, AppRoutes.myBookings),
            icon: const Icon(Icons.check_circle),
            label: const Text('Xem lịch đã đặt'),
          )
        else
          OutlinedButton.icon(
            onPressed: provider.isChecking ? null : provider.refresh,
            icon: provider.isChecking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Kiểm tra lại ngay'),
          ),
      ],
    );
  }

  Widget _buildNoQr(PaymentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 8),
          const Text('Chưa tạo được mã QR.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: provider.isChecking ? null : provider.refresh,
            child: const Text('Thử tạo lại'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (payment.status) {
      'PAID' => ('Đã thanh toán', Colors.green, Icons.check_circle),
      'CANCELLED' => ('Đã hủy', Colors.red, Icons.cancel),
      'EXPIRED' => ('Đã hết hạn', Colors.red, Icons.timer_off),
      'PROCESSING' => ('Đang xử lý thanh toán', Colors.blue, Icons.sync),
      _ => ('Đang chờ thanh toán', Colors.orange, Icons.schedule),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
