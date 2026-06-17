import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class CreateExaminationResultPage extends StatelessWidget {
  const CreateExaminationResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Create Examination Result',
      message: 'Create Examination Result Page',
      actions: [
        PageAction(
          label: 'Result Detail',
          routeName: AppRoutes.examinationResultDetail,
        ),
      ],
    );
  }
}
