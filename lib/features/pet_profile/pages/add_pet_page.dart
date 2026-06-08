import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class AddPetPage extends StatelessWidget {
  const AddPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Add Pet',
      message: 'Add Pet Page',
      actions: [PageAction(label: 'Pet List', routeName: AppRoutes.petList)],
    );
  }
}
