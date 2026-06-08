import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class EditUserProfilePage extends StatelessWidget {
  const EditUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Edit User Profile',
      message: 'Edit User Profile Page',
      actions: [PageAction(label: 'Profile', routeName: AppRoutes.userProfile)],
    );
  }
}
