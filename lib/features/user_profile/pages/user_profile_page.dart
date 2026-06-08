import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'User Profile',
      message: 'User Profile Page',
      actions: [
        PageAction(label: 'Edit Profile', routeName: AppRoutes.editUserProfile),
      ],
    );
  }
}
