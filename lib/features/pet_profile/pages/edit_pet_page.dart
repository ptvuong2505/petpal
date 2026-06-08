import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class EditPetPage extends StatelessWidget {
  const EditPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Edit Pet',
      message: 'Edit Pet Page',
      actions: [
        PageAction(label: 'Pet Detail', routeName: AppRoutes.petDetail),
      ],
    );
  }
}
