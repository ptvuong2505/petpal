import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'My Reviews',
      message: 'My Reviews Page',
      actions: [
        PageAction(label: 'Review List', routeName: AppRoutes.reviewList),
      ],
    );
  }
}
