import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ReviewListPage extends StatelessWidget {
  const ReviewListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Review List',
      message: 'Review List Page',
      actions: [
        PageAction(label: 'Review Detail', routeName: AppRoutes.reviewDetail),
        PageAction(label: 'Create Review', routeName: AppRoutes.createReview),
      ],
    );
  }
}
