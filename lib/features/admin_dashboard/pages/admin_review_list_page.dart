import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../review/data/review_dao.dart';

class AdminReviewListPage extends StatefulWidget {
  const AdminReviewListPage({super.key});

  @override
  State<AdminReviewListPage> createState() => _AdminReviewListPageState();
}

class _AdminReviewListPageState extends State<AdminReviewListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ReviewDao _reviewDao = ReviewDao();

  List<Map<String, Object?>> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _reviewDao.getAllReviewsForAdmin();
      if (!mounted) return;
      setState(() {
        _reviews = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được danh sách review.';
        _isLoading = false;
      });
    }
  }

  List<Map<String, Object?>> get _filteredReviews {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _reviews;

    return _reviews.where((review) {
      final serviceName = _text(review['service_name']).toLowerCase();
      final staffName = _text(review['staff_name']).toLowerCase();
      return serviceName.contains(query) || staffName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReviews = _filteredReviews;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên dịch vụ hoặc tên staff',
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
            '${filteredReviews.length} review',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildContent(filteredReviews)),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, Object?>> reviews) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _AdminReviewEmptyState(
        icon: Icons.error_outline,
        message: _errorMessage!,
        actionLabel: 'Thử lại',
        onAction: _loadReviews,
      );
    }
    if (reviews.isEmpty) {
      return _AdminReviewEmptyState(
        icon: Icons.rate_review_outlined,
        message: _searchController.text.trim().isEmpty
            ? 'Chưa có review nào.'
            : 'Không tìm thấy review phù hợp.',
        actionLabel: _searchController.text.trim().isEmpty
            ? null
            : 'Xóa tìm kiếm',
        onAction: _searchController.text.trim().isEmpty
            ? null
            : _searchController.clear,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: reviews.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _AdminReviewCard(
            review: review,
            onTap: () => NavigationService.goTo(
              context,
              AppRoutes.adminReviewDetail,
              queryParameters: {'reviewId': _text(review['id'])},
            ),
          );
        },
      ),
    );
  }
}

class _AdminReviewCard extends StatelessWidget {
  const _AdminReviewCard({required this.review, required this.onTap});

  final Map<String, Object?> review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                      _text(review['service_name'], fallback: 'Dịch vụ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RatingStars(rating: _rating(review['rating'])),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _text(review['comment'], fallback: 'Không có nội dung review.'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _MetaItem(
                    icon: Icons.person_outline,
                    text: _text(review['user_name'], fallback: 'Khách hàng'),
                  ),
                  _MetaItem(
                    icon: Icons.badge_outlined,
                    text: _text(
                      review['staff_name'],
                      fallback: 'Chưa có staff',
                    ),
                  ),
                  _MetaItem(
                    icon: Icons.calendar_month_outlined,
                    text: _dateLabel(review['created_at']),
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
            size: 16,
          ),
      ],
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

class _AdminReviewEmptyState extends StatelessWidget {
  const _AdminReviewEmptyState({
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

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _rating(Object? value) {
  if (value is int) return value.clamp(0, 5);
  if (value is num) return value.toInt().clamp(0, 5);
  return int.tryParse(_text(value))?.clamp(0, 5) ?? 0;
}

String _dateLabel(Object? value) {
  final text = _text(value);
  if (text.length >= 10) return text.substring(0, 10);
  return text.isEmpty ? 'Chưa có ngày' : text;
}
