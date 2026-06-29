import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/navigation_service.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    required this.title,
    required this.child,
    this.currentRouteName,
    this.showBottomNav = true,
    this.showBackButton = true,
    this.constrainTitle = false,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget child;
  final String? currentRouteName;
  final bool showBottomNav;
  final bool showBackButton;
  final bool constrainTitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final canShowBackButton = showBackButton && Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: canShowBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => NavigationService.goBack(context),
              )
            : null,
        title: Row(
          children: [
            if (!canShowBackButton) ...[
              CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
            ],
            if (constrainTitle)
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: actions,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav
          ? AppBottomNavigationBar(
              currentRouteName: currentRouteName ?? "Petpal",
            )
          : null,
    );
  }
}
