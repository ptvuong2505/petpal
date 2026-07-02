import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../booking/data/booking_dao.dart';

class AdminBookingDetailPage extends StatefulWidget {
  const AdminBookingDetailPage({required this.bookingId, super.key});

  final int bookingId;

  @override
  State<AdminBookingDetailPage> createState() => _AdminBookingDetailPageState();
}

class _AdminBookingDetailPageState extends State<AdminBookingDetailPage> {
  final BookingDao _bookingDao = BookingDao();

  Map<String, Object?>? _booking;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _bookingDao.getBookingById(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _booking = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được chi tiết booking.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final booking = _booking;
    if (_errorMessage != null || booking == null) {
      return _DetailStateView(
        icon: Icons.event_busy_outlined,
        message: _errorMessage ?? 'Không tìm thấy booking.',
        onRetry: _loadBooking,
      );
    }

    final status = _text(booking['status'], fallback: 'pending');
    final statusStyle = _statusStyle(status);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _HeaderCard(
              booking: booking,
              statusLabel: _statusLabel(status),
              statusColor: statusStyle.$1,
              statusTextColor: statusStyle.$2,
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Thông tin booking',
              icon: Icons.event_note_outlined,
              rows: [
                _InfoRowData(
                  label: 'Mã booking',
                  value: '#PP-${_text(booking['id'])}',
                ),
                _InfoRowData(
                  label: 'Dịch vụ',
                  value: _text(booking['service_name'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Ngày hẹn',
                  value: _text(booking['booking_date'], fallback: '-'),
                ),
                _InfoRowData(label: 'Thời gian', value: _timeRange(booking)),
                _InfoRowData(
                  label: 'Nhân viên',
                  value: _text(
                    booking['staff_name'],
                    fallback: 'Chưa phân công',
                  ),
                ),
                _InfoRowData(
                  label: 'Ghi chú',
                  value: _text(booking['note'], fallback: '-'),
                ),
              ],
            ),
            _InfoSection(
              title: 'Khách hàng',
              icon: Icons.person_outline,
              rows: [
                _InfoRowData(
                  label: 'Họ tên',
                  value: _text(booking['customer_name'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Email',
                  value: _text(booking['customer_email'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Số điện thoại',
                  value: _text(booking['customer_phone'], fallback: '-'),
                ),
              ],
            ),
            _InfoSection(
              title: 'Thú cưng',
              icon: Icons.pets_outlined,
              rows: [
                _InfoRowData(
                  label: 'Tên',
                  value: _text(booking['pet_name'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Loài',
                  value: _text(booking['pet_species'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Cân nặng',
                  value: _weightValue(booking['pet_weight']),
                ),
              ],
            ),
            _InfoSection(
              title: 'Thanh toán',
              icon: Icons.payments_outlined,
              rows: [
                _InfoRowData(
                  label: 'Tổng tiền',
                  value: _currencyValue(booking['total_price']),
                  emphasize: true,
                ),
                _InfoRowData(
                  label: 'Ngày tạo',
                  value: _text(booking['created_at'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Cập nhật',
                  value: _text(booking['updated_at'], fallback: '-'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.statusTextColor,
  });

  final Map<String, Object?> booking;
  final String statusLabel;
  final Color statusColor;
  final Color statusTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(booking['service_name'], fallback: 'Dịch vụ'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _HeaderMeta(
                icon: Icons.confirmation_number_outlined,
                text: '#PP-${_text(booking['id'])}',
              ),
              _HeaderMeta(
                icon: Icons.calendar_month_outlined,
                text: _text(booking['booking_date'], fallback: 'Chưa có ngày'),
              ),
              _HeaderMeta(
                icon: Icons.schedule_outlined,
                text: _timeRange(booking),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < rows.length; index++) ...[
            _InfoRow(data: rows[index]),
            if (index != rows.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoRowData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            data.label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            data.value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: data.emphasize ? AppColors.primary : AppColors.text,
              fontSize: 14,
              fontWeight: data.emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRowData {
  const _InfoRowData({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;
}

class _DetailStateView extends StatelessWidget {
  const _DetailStateView({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _timeRange(Map<String, Object?> booking) {
  final startTime = _text(booking['start_time']);
  final endTime = _text(booking['end_time']);
  if (startTime.isEmpty && endTime.isEmpty) return 'Chưa có giờ';
  if (endTime.isEmpty) return startTime;
  return '$startTime - $endTime';
}

String _weightValue(Object? value) {
  final weight =
      value is num ? value.toDouble() : double.tryParse(_text(value));
  if (weight == null || weight <= 0) return '-';
  return '${weight.toStringAsFixed(1)} kg';
}

String _currencyValue(Object? value) {
  final amount =
      value is num ? value.toDouble() : double.tryParse(_text(value));
  if (amount == null) return '-';
  return '${amount.toStringAsFixed(0)}đ';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return 'Đã xác nhận';
    case 'completed':
      return 'Hoàn thành';
    case 'cancelled':
      return 'Đã hủy';
    case 'pending':
      return 'Đang chờ';
    default:
      return status;
  }
}

(Color, Color) _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return (AppColors.primaryContainer, AppColors.primary);
    case 'completed':
      return (AppColors.secondaryContainer, AppColors.secondary);
    case 'cancelled':
      return (AppColors.errorContainer, AppColors.error);
    case 'pending':
    default:
      return (AppColors.tertiaryContainer, AppColors.tertiary);
  }
}
