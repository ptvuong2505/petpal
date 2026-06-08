import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class StaffBookingDetailPage extends StatelessWidget {
  const StaffBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Staff Booking Detail',
      message: 'Staff Booking Detail Page',
      actions: [
        PageAction(
          label: 'Create Result',
          routeName: AppRoutes.createExaminationResult,
        ),
      ],
    );
  }
}
