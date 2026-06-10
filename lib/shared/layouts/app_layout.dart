import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    required this.title,
    required this.child,
    this.currentRouteName,
    this.showBottomNav = true,
    this.actions,
    super.key,
  });

  final String title;
  final Widget child;
  final String? currentRouteName;
  final bool showBottomNav;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions:
            actions ??
            [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.textMuted,
                ),
              ),
            ],
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: child),
      bottomNavigationBar: showBottomNav
          ? AppBottomNavigationBar(
              currentRouteName: currentRouteName ?? "Petpal",
            )
          : null,
    );
  }
}
