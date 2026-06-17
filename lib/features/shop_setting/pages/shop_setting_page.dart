import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ShopSettingPage extends StatelessWidget {
  const ShopSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Shop Setting',
      message: 'Shop Setting Page',
      actions: [
        PageAction(
          label: 'Admin Dashboard',
          routeName: AppRoutes.adminDashboard,
        ),
      ],
    );
  }
}
