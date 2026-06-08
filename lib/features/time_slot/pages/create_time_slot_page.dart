import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class CreateTimeSlotPage extends StatelessWidget {
  const CreateTimeSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Create Time Slot',
      message: 'Create Time Slot Page',
      actions: [
        PageAction(
          label: 'Time Slot Management',
          routeName: AppRoutes.timeSlotManagement,
        ),
      ],
    );
  }
}
