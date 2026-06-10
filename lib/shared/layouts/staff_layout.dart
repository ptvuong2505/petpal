import 'package:flutter/material.dart';

import 'app_layout.dart';

class StaffLayout extends StatelessWidget {
  const StaffLayout({
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
      child: child,
    );
  }
}
