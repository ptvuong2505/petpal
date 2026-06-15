import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';

class StaffMorePage extends StatelessWidget {
  const StaffMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Thống kê'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              NavigationService.goTo(context, AppRoutes.staffStatistics),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Hồ sơ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => NavigationService.goTo(context, AppRoutes.staffProfile),
        ),
      ],
    );
  }
}
