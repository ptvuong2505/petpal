import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../review/data/review_dao.dart';

class AdminReviewDetailPage extends StatefulWidget {
  const AdminReviewDetailPage({required this.reviewId, super.key});

  final int reviewId;

  @override
  State<AdminReviewDetailPage> createState() => _AdminReviewDetailPageState();
}

class _AdminReviewDetailPageState extends State<AdminReviewDetailPage> {
  final ReviewDao _reviewDao = ReviewDao();

  Map<String, Object?>? _review;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _reviewDao.getReviewByIdForAdmin(widget.reviewId);
      if (!mounted) return;
      setState(() {
        _review = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được chi tiết review.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final review = _review;
    if (_errorMessage != null || review == null) {
      return _DetailStateView(
        icon: Icons.rate_review_outlined,
        message: _errorMessage ?? 'Không tìm thấy review.',
        onRetry: _loadReview,
      );
    }

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _loadReview,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _ReviewHeaderCard(review: review),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Thông tin review',
              icon: Icons.rate_review_outlined,
              rows: [
                _InfoRowData(
                  label: 'Mã review',
                  value: '#RV-${_text(review['id'])}',
                ),
                _InfoRowData(
                  label: 'Đánh giá',
                  value: '${_rating(review['rating'])}/5',
                  emphasize: true,
                ),
                _InfoRowData(
                  label: 'Ngày tạo',
                  value: _text(review['created_at'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Cập nhật',
                  value: _text(review['updated_at'], fallback: '-'),
                ),
              ],
            ),
            _InfoSection(
              title: 'Khách hàng',
              icon: Icons.person_outline,
              rows: [
                _InfoRowData(
                  label: 'Họ tên',
                  value: _text(review['user_name'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Email',
                  value: _text(review['user_email'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Số điện thoại',
                  value: _text(review['user_phone'], fallback: '-'),
                ),
              ],
            ),
            _InfoSection(
              title: 'Dịch vụ và nhân viên',
              icon: Icons.medical_services_outlined,
              rows: [
                _InfoRowData(
                  label: 'Dịch vụ',
                  value: _text(review['service_name'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Staff',
                  value: _text(review['staff_name'], fallback: 'Chưa có staff'),
                ),
                _InfoRowData(label: 'Thú cưng', value: _petLabel(review)),
              ],
            ),
            _InfoSection(
              title: 'Booking liên quan',
              icon: Icons.event_note_outlined,
              rows: [
                _InfoRowData(
                  label: 'Mã booking',
                  value: '#PP-${_text(review['booking_id'])}',
                ),
                _InfoRowData(
                  label: 'Ngày hẹn',
                  value: _text(review['booking_date'], fallback: '-'),
                ),
                _InfoRowData(label: 'Thời gian', value: _timeRange(review)),
                _InfoRowData(
                  label: 'Trạng thái',
                  value: _text(review['booking_status'], fallback: '-'),
                ),
                _InfoRowData(
                  label: 'Tổng tiền',
                  value: _currencyValue(review['total_price']),
                ),
                _InfoRowData(
                  label: 'Ghi chú booking',
                  value: _text(review['booking_note'], fallback: '-'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeaderCard extends StatelessWidget {
  const _ReviewHeaderCard({required this.review});

  final Map<String, Object?> review;

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
                  _text(review['service_name'], fallback: 'Dịch vụ'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              _RatingStars(rating: _rating(review['rating'])),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _text(review['comment'], fallback: 'Không có nội dung review.'),
            style: const TextStyle(
              color: AppColors.subText,
              fontSize: 15,
              height: 22 / 15,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _HeaderMeta(
                icon: Icons.person_outline,
                text: _text(review['user_name'], fallback: 'Khách hàng'),
              ),
              _HeaderMeta(
                icon: Icons.badge_outlined,
                text: _text(review['staff_name'], fallback: 'Chưa có staff'),
              ),
              _HeaderMeta(
                icon: Icons.calendar_month_outlined,
                text: _dateLabel(review['created_at']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFB400),
            size: 18,
          ),
      ],
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
          width: 116,
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

int _rating(Object? value) {
  if (value is int) return value.clamp(0, 5);
  if (value is num) return value.toInt().clamp(0, 5);
  return int.tryParse(_text(value))?.clamp(0, 5) ?? 0;
}

String _petLabel(Map<String, Object?> review) {
  final petName = _text(review['pet_name'], fallback: '-');
  final species = _text(review['pet_species']);
  return species.isEmpty || petName == '-' ? petName : '$petName ($species)';
}

String _timeRange(Map<String, Object?> review) {
  final startTime = _text(review['start_time']);
  final endTime = _text(review['end_time']);
  if (startTime.isEmpty && endTime.isEmpty) return '-';
  if (endTime.isEmpty) return startTime;
  return '$startTime - $endTime';
}

String _currencyValue(Object? value) {
  final amount =
      value is num ? value.toDouble() : double.tryParse(_text(value));
  if (amount == null) return '-';
  return '${amount.toStringAsFixed(0)}đ';
}

String _dateLabel(Object? value) {
  final text = _text(value);
  if (text.length >= 10) return text.substring(0, 10);
  return text.isEmpty ? 'Chưa có ngày' : text;
}
