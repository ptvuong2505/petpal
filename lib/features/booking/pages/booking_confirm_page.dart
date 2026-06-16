import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';

class BookingConfirmPage extends StatefulWidget {
  const BookingConfirmPage({super.key});
  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  bool _isLoading = false;
  final Map<int, Map<String, Object?>> _serviceDetails = {};
  Map<String, Object?>? _petDetails;
  Map<String, Object?>? _slotDetails;
  double _totalPrice = 0;
  final TextEditingController _noteController = TextEditingController();
  static const double serviceFee = 15000;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails() async {
    final provider = context.read<BookingProvider>();
    final db = await AppDatabase.instance.database;
    if (provider.selectedServiceIds.isNotEmpty) {
      for (final sId in provider.selectedServiceIds) {
        final rows = await db.query(
          'services',
          where: 'id = ?',
          whereArgs: [sId],
        );
        if (rows.isNotEmpty) {
          _serviceDetails[sId] = rows.first;
          _totalPrice += ((rows.first['price'] as num?) ?? 0).toDouble();
        }
      }
    }
    if (provider.selectedPetId != null) {
      final rows = await db.query(
        'pets',
        where: 'id = ?',
        whereArgs: [provider.selectedPetId],
      );
      if (rows.isNotEmpty) _petDetails = rows.first;
    }
    if (provider.selectedTimeSlotId != null) {
      final rows = await db.query(
        'time_slots',
        where: 'id = ?',
        whereArgs: [provider.selectedTimeSlotId],
      );
      if (rows.isNotEmpty) _slotDetails = rows.first;
    }
    setState(() {});
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<BookingProvider>();
      final auth = context.read<AuthProvider>();
      final db = await AppDatabase.instance.database;
      final nowDt = DateTime.now();
      final nowText = nowDt.toIso8601String();
      final userId = auth.currentUser?.id ?? 0;
      final petId = provider.selectedPetId;
      final timeSlotId = provider.selectedTimeSlotId;
      final serviceNames = _serviceDetails.values
          .map((s) => (s['name'] as String?) ?? '')
          .join(', ');
      final bookingId = await db.insert('bookings', {
        'user_id': userId,
        'pet_id': petId,
        'service_id': provider.selectedServiceIds.isNotEmpty
            ? provider.selectedServiceIds.first
            : null,
        'time_slot_id': timeSlotId,
        'service_name': serviceNames,
        'booking_date':
            (_slotDetails?['slot_date'] as String?) ??
            DateTime.now().toIso8601String().substring(0, 10),
        'note': _noteController.text,
        'total_price': _totalPrice + serviceFee,
        'status': 'pending',
        'created_at': nowText,
        'updated_at': nowText,
      });
      if (timeSlotId != null) {
        final currentCount = ((_slotDetails?['booked_count'] as int?) ?? 0);
        await db.update(
          'time_slots',
          {'booked_count': currentCount + 1, 'updated_at': nowText},
          where: 'id = ?',
          whereArgs: [timeSlotId],
        );
      }
      provider.lastCreatedBookingId = bookingId;
      provider.resetBookingFlow();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đặt lịch thành công')));
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) NavigationService.goTo(context, AppRoutes.createReview);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWithFee = _totalPrice + serviceFee;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận đặt lịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned.fill(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE4E2E2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.content_cut,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _serviceDetails.values
                                              .map(
                                                (s) =>
                                                    (s['name'] as String?) ??
                                                    '',
                                              )
                                              .join(' & '),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _serviceDetails.values
                                              .map(
                                                (s) =>
                                                    (s['description']
                                                        as String?) ??
                                                    '',
                                              )
                                              .join(', '),
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${_totalPrice.toInt()}đ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: const Color(0xFFE4E2E2),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.secondaryContainer,
                                    child: const Icon(
                                      Icons.pets,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_petDetails?['name'] as String?) ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${(_petDetails?['species'] as String?) ?? ''} • ${(_petDetails?['weight'] as num?)?.toStringAsFixed(1) ?? ''}kg',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: const Color(0xFFE4E2E2),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.calendar_month,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ngày hẹn',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    (_slotDetails?['slot_date'] as String?) ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.schedule,
                                        color: AppColors.textMuted,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Thời gian',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(_slotDetails?['start_time'] as String?) ?? ''} - ${(_slotDetails?['end_time'] as String?) ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Ghi chú cho spa (Tùy chọn)',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: Bé nhát người lạ, xin nhẹ tay...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFBFC9C3),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFBFC9C3),
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tạm tính',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${_totalPrice.toInt()}đ',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí dịch vụ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${serviceFee.toInt()}đ',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 1,
                                color: const Color(
                                  0xFFBFC9C3,
                                ).withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng cộng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${totalWithFee.toInt()}đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: const Color(0xFFE4E2E2)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text(
                              'Xác nhận đặt lịch',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
