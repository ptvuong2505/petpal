import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class HealthRecordListPage extends StatelessWidget {
  const HealthRecordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Health Records',
      message: 'Health Record List Page',
      actions: [
        PageAction(
          label: 'Health Record Detail',
          routeName: AppRoutes.healthRecordDetail,
        ),
      ],
    );
  }
}
