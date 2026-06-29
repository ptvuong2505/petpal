import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import 'app_layout.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({
    required this.title,
    required this.child,
    required this.currentRouteName,
    super.key,
  });

  final String title;
  final Widget child;
  final String currentRouteName;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: title,
      currentRouteName: currentRouteName,
      showBackButton: currentRouteName != AppRoutes.adminDashboard,
      child: child,
    );
  }
}
