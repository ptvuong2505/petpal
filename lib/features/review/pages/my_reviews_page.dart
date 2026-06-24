import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Use layout background
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryStats(provider),
                const SizedBox(height: 24),
                _buildHeaderActions(context),
                const SizedBox(height: 16),
                if (provider.reviews.isEmpty)
                  _buildEmptyState()
                else
                  ...provider.reviews.map((review) => _buildReviewCard(review)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NavigationService.goTo(context, AppRoutes.myBookings),
        label: const Text('Viết đánh giá'),
        icon: const Icon(Icons.edit),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Đánh giá của bạn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1C1C),
          ),
        ),
        TextButton.icon(
          onPressed: () =>
              NavigationService.goTo(context, AppRoutes.reviewList),
          icon: const Icon(Icons.public, size: 18),
          label: const Text('Xem cộng đồng'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(ReviewProvider provider) {
    final avgRating = provider.reviews.isEmpty
        ? 0.0
        : provider.reviews.fold(0, (sum, r) => sum + r.rating) /
              provider.reviews.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          provider.reviews.length.toString(),
          'Reviews\nWritten',
          color: AppColors.primary,
        ),
        _buildStatCard(
          avgRating.toStringAsFixed(1),
          'Average\nRating',
          icon: Icons.star,
          iconColor: const Color(0xFFFFB400),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label, {
    Color? color,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E2E2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color ?? AppColors.primary,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, color: iconColor, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF404945)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ReviewProvider>().deleteReview(review.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đánh giá')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E2E2).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD0TvL3URfGHcUVp-8KjP5usyJ9MBgz2X7w0OGCRqoQlumSaaqyj_DmQpUFP4W5Y6THZuXkRqeQMNxWthBssxDItjWK-eHkboP1HmkiOwNTLsrPAF2V_Oq_q1MGciErIGkRck3ZrUo7mN5A7nvWtCkwkrX9OaZhq3gWGbsf_wi_5tA18qCe1GJh1uRf51X04W5SiDUFKnD8XOAb8NaOeOSWbE6ga_roTn-x0Wff1iwvvLW9Iaq2ywiiLlg18Rc48F_csAwlZHBX0PI',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                    Text(
                      '${review.serviceName ?? 'Dịch vụ'} • ${review.createdAt?.substring(0, 10) ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF404945),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: const Color(0xFFFFB400),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      NavigationService.goTo(
                        context,
                        AppRoutes.createReview,
                        arguments: review,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, review),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1B1C1C),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA7Tjut03z1KeC6p5EPSPy0Lluw9GhUIlvxovJPzmd5y0rVbFNUr7ns7hbAF5TrOSajBtpXIhJ02ddwtQ2dvVbkCnmBfoLrwiR53LNJg5dCZOvemDnUuOoJ-qruutg7KN7njdph2mTQnqotkgcpHswT_1ewxgzllgcrIEpW1T7WWF25-v-ZDrJqJlEHwQPfXCbLzWOdvGlTVkTxBu0sd5p68xkTjn-YeX5o71FrvReWLNV8okFasNr_S9HH2HVNYKt7DhpSSBk1yr4',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reviewed for ${review.petName ?? 'Pet'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF404945),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDED),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.rate_review,
              size: 48,
              color: Color(0xFF707974),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When you leave feedback for sitters and walkers, they\'ll appear here in your personal archive.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF404945)),
            ),
          ),
        ],
      ),
    );
  }
}
