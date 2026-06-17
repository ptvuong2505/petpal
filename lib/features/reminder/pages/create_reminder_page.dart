import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class CreateReminderPage extends StatelessWidget {
  const CreateReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Create Reminder',
      message: 'Create Reminder Page',
      actions: [
        PageAction(label: 'Reminder List', routeName: AppRoutes.reminderList),
      ],
    );
  }
}
