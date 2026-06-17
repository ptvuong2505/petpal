import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class StaffBookingListPage extends StatelessWidget {
  const StaffBookingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Staff Booking List',
      message: 'Staff Booking List Page',
      actions: [
        PageAction(
          label: 'Staff Booking Detail',
          routeName: AppRoutes.staffBookingDetail,
        ),
      ],
    );
  }
}
