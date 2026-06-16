import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final userBookings = provider.bookings;

        if (userBookings.isEmpty) {
          return const Center(child: Text('Bạn chưa có đơn đặt lịch nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: userBookings.length,
          itemBuilder: (context, index) {
            final booking = userBookings[index];
            return _buildBookingCard(context, booking);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    bool isCompleted = booking.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ngày: ${booking.bookingDate}'),
          Text('Tổng tiền: ${booking.totalPrice.toInt()}đ'),
          const SizedBox(height: 12),
          if (isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.goTo(
                    context,
                    AppRoutes.createReview,
                    arguments: booking.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Đánh giá dịch vụ'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'completed':
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'Đã xác nhận';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ xử lý';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
