import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Pet Detail',
      message: 'Pet Detail Page',
      actions: [
        PageAction(label: 'Edit Pet', routeName: AppRoutes.editPet),
        PageAction(
          label: 'Health Records',
          routeName: AppRoutes.healthRecordList,
        ),
      ],
    );
  }
}
