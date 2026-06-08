import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class HealthRecordDetailPage extends StatelessWidget {
  const HealthRecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Health Record Detail',
      message: 'Health Record Detail Page',
      actions: [
        PageAction(
          label: 'Health Records',
          routeName: AppRoutes.healthRecordList,
        ),
      ],
    );
  }
}
