import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Reminder List',
      message: 'Reminder List Page',
      actions: [
        PageAction(
          label: 'Create Reminder',
          routeName: AppRoutes.createReminder,
        ),
        PageAction(label: 'Edit Reminder', routeName: AppRoutes.editReminder),
      ],
    );
  }
}
