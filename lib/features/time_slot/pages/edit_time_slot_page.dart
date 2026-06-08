import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class EditTimeSlotPage extends StatelessWidget {
  const EditTimeSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Edit Time Slot',
      message: 'Edit Time Slot Page',
      actions: [
        PageAction(
          label: 'Time Slot Management',
          routeName: AppRoutes.timeSlotManagement,
        ),
      ],
    );
  }
}
