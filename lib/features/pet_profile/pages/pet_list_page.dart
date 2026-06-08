import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class PetListPage extends StatelessWidget {
  const PetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Pet List',
      message: 'Pet List Page',
      actions: [
        PageAction(label: 'Add Pet', routeName: AppRoutes.addPet),
        PageAction(label: 'Pet Detail', routeName: AppRoutes.petDetail),
      ],
    );
  }
}
