import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Staff Dashboard',
      message: 'Staff Dashboard Page',
      actions: [
        PageAction(
          label: 'Staff Bookings',
          routeName: AppRoutes.staffBookingList,
        ),
        PageAction(label: 'Reminders', routeName: AppRoutes.reminderList),
      ],
    );
  }
}
