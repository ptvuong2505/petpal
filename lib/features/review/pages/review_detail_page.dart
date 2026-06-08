import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ReviewDetailPage extends StatelessWidget {
  const ReviewDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Review Detail',
      message: 'Review Detail Page',
      actions: [
        PageAction(label: 'Review List', routeName: AppRoutes.reviewList),
      ],
    );
  }
}
