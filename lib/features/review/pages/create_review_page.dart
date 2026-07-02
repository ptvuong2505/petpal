import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/models/booking.dart';
import '../../booking/providers/booking_provider.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key, this.bookingId, this.review});

  final int? bookingId;
  final Review? review;

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  Booking? _booking;
  bool _isLoadingBooking = true;

  final List<String> _feedbackTexts = [
    "Tệ",
    "Không hài lòng",
    "Bình thường",
    "Hài lòng",
    "Tuyệt vời!",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _rating = widget.review!.rating;
      _commentController.text = widget.review!.comment ?? '';
    }
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final bookingProvider = context.read<BookingProvider>();
    final bId = widget.review?.bookingId ??
        widget.bookingId ??
        bookingProvider.lastCreatedBookingId;

    if (bId == null) {
      setState(() => _isLoadingBooking = false);
      return;
    }

    final db = await AppDatabase.instance.database;
    final rows = await db.query('bookings', where: 'id = ?', whereArgs: [bId]);

    if (rows.isNotEmpty) {
      setState(() {
        _booking = Booking.fromMap(rows.first);
        _isLoadingBooking = false;
      });
    } else {
      setState(() {
        _isLoadingBooking = false;
        _booking = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin lịch hẹn.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao để đánh giá')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final reviewProvider = context.read<ReviewProvider>();

      if (widget.review != null) {
        // Update existing review
        final updatedReview = Review(
          id: widget.review!.id,
          userId: widget.review!.userId,
          bookingId: widget.review!.bookingId,
          petId: widget.review!.petId,
          rating: _rating,
          comment: _commentController.text,
          createdAt: widget.review!.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await reviewProvider.updateReview(updatedReview);
      } else {
        // Create new review
        if (_booking == null) {
          throw Exception('Không tìm thấy thông tin lịch hẹn để đánh giá');
        }
        final review = Review(
          userId: authProvider.currentUser?.id ?? 0,
          bookingId: _booking!.id!,
          petId: _booking!.petId,
          rating: _rating,
          comment: _commentController.text,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await reviewProvider.createReview(review);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.review != null
                  ? 'Cập nhật đánh giá thành công!'
                  : 'Gửi đánh giá thành công!',
            ),
          ),
        );
        NavigationService.goTo(context, AppRoutes.myReviews);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBooking) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Booking Summary Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDnXtSdgVhkPl4glcjfhx6J-lC7V2TzaQr1btLwplEVo-u3ZZKZQbMtCZ0h798VcaaIcH5M_K-BWKHNuzPa5rsOVu_-FDLLTMtClB9GUvx4eSV-fv5wwF0riubmRLCHqrCDwLsGor8N8OEKvIzfyZQMpK2kTA53-oIYlgQPwMiY2Vdbe6_mIhne-2vEVEhBFBqcQZa3sRKbkgDuOwfW1_s3kynxyCZQT90rEBKsrrdjicA_nkp_FKjwcG5nP14z_eUk8oapubYgspk',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _booking?.serviceName ?? 'Dịch vụ PetPal',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            const TextSpan(text: 'Người chăm sóc: '),
                            TextSpan(
                              text: 'Nguyễn Văn A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _booking?.bookingDate ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Rating Section
          Text(
            widget.review != null
                ? 'Chỉnh sửa đánh giá của bạn'
                : 'Bạn đánh giá dịch vụ thế nào?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng chọn số sao để đánh giá.',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starValue;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    _rating >= starValue ? Icons.star : Icons.star_border,
                    size: 40,
                    color: _rating >= starValue
                        ? const Color(0xFFFFB02E)
                        : AppColors.outlineVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _rating > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating > 0 ? _feedbackTexts[_rating - 1] : '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Feedback Form
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Chia sẻ thêm về trải nghiệm của bạn (Tuỳ chọn)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung đánh giá của bạn...',
              hintStyle: const TextStyle(color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: const Color(0xFF4A4A4A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.review != null ? 'Cập nhật' : 'Gửi đánh giá',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
