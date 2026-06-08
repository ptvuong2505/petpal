import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class CreateReviewPage extends StatelessWidget {
  const CreateReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Create Review',
      message: 'Create Review Page',
      actions: [
        PageAction(label: 'My Reviews', routeName: AppRoutes.myReviews),
      ],
    );
  }
}
