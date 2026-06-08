import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Admin Dashboard',
      message: 'Admin Dashboard Page',
      actions: [
        PageAction(label: 'Shop Setting', routeName: AppRoutes.shopSetting),
        PageAction(
          label: 'Time Slots',
          routeName: AppRoutes.timeSlotManagement,
        ),
        PageAction(label: 'Reviews', routeName: AppRoutes.reviewList),
      ],
    );
  }
}
