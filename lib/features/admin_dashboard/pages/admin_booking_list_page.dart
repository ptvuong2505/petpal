import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../booking/data/booking_dao.dart';

class AdminBookingListPage extends StatefulWidget {
  const AdminBookingListPage({super.key});

  @override
  State<AdminBookingListPage> createState() => _AdminBookingListPageState();
}

class _AdminBookingListPageState extends State<AdminBookingListPage> {
  final TextEditingController _searchController = TextEditingController();
  final BookingDao _bookingDao = BookingDao();

  List<Map<String, Object?>> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _bookingDao.getAllBookingsForAdmin();
      if (!mounted) return;
      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được danh sách booking.';
        _isLoading = false;
      });
    }
  }

  List<Map<String, Object?>> get _filteredBookings {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _bookings;

    return _bookings.where((booking) {
      final serviceName = _text(booking['service_name']).toLowerCase();
      final petName = _text(booking['pet_name']).toLowerCase();
      return serviceName.contains(query) || petName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _filteredBookings;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên dịch vụ hoặc tên pet',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${filteredBookings.length} booking',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildContent(filteredBookings)),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, Object?>> bookings) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _AdminEmptyState(
        icon: Icons.error_outline,
        message: _errorMessage!,
        actionLabel: 'Thử lại',
        onAction: _loadBookings,
      );
    }
    if (bookings.isEmpty) {
      return _AdminEmptyState(
        icon: Icons.event_busy_outlined,
        message: _searchController.text.trim().isEmpty
            ? 'Chưa có booking nào.'
            : 'Không tìm thấy booking phù hợp.',
        actionLabel: _searchController.text.trim().isEmpty
            ? null
            : 'Xóa tìm kiếm',
        onAction: _searchController.text.trim().isEmpty
            ? null
            : _searchController.clear,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _AdminBookingCard(
            booking: booking,
            onTap: () => NavigationService.goTo(
              context,
              AppRoutes.adminBookingDetail,
              queryParameters: {'bookingId': _text(booking['id'])},
            ),
          );
        },
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  const _AdminBookingCard({required this.booking, required this.onTap});

  final Map<String, Object?> booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _text(booking['status'], fallback: 'pending');
    final statusStyle = _statusStyle(status);
    final timeRange = _timeRange(booking);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _text(booking['service_name'], fallback: 'Dịch vụ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: _statusLabel(status),
                    color: statusStyle.$1,
                    textColor: statusStyle.$2,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.pets_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _petLabel(booking),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#PP-${_text(booking['id'])}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _MetaItem(
                    icon: Icons.calendar_month_outlined,
                    text: _text(
                      booking['booking_date'],
                      fallback: 'Chưa có ngày',
                    ),
                  ),
                  _MetaItem(icon: Icons.schedule_outlined, text: timeRange),
                  _MetaItem(
                    icon: Icons.person_outline,
                    text: _text(
                      booking['customer_name'],
                      fallback: 'Khách hàng',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _petLabel(Map<String, Object?> booking) {
  final petName = _text(booking['pet_name'], fallback: 'Pet');
  final species = _text(booking['pet_species']);
  return species.isEmpty ? petName : '$petName ($species)';
}

String _timeRange(Map<String, Object?> booking) {
  final startTime = _text(booking['start_time']);
  final endTime = _text(booking['end_time']);
  if (startTime.isEmpty && endTime.isEmpty) return 'Chưa có giờ';
  if (endTime.isEmpty) return startTime;
  return '$startTime - $endTime';
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
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
