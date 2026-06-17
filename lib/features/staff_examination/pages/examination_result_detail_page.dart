import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ExaminationResultDetailPage extends StatelessWidget {
  const ExaminationResultDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Examination Result Detail',
      message: 'Examination Result Detail Page',
      actions: [
        PageAction(
          label: 'Staff Dashboard',
          routeName: AppRoutes.staffDashboard,
        ),
      ],
    );
  }
}
