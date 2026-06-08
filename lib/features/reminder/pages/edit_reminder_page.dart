import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class EditReminderPage extends StatelessWidget {
  const EditReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Edit Reminder',
      message: 'Edit Reminder Page',
      actions: [
        PageAction(label: 'Reminder List', routeName: AppRoutes.reminderList),
      ],
    );
  }
}
