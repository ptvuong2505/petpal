import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class TimeSlotManagementPage extends StatelessWidget {
  const TimeSlotManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Time Slot Management',
      message: 'Time Slot Management Page',
      actions: [
        PageAction(
          label: 'Create Time Slot',
          routeName: AppRoutes.createTimeSlot,
        ),
        PageAction(label: 'Edit Time Slot', routeName: AppRoutes.editTimeSlot),
      ],
    );
  }
}
