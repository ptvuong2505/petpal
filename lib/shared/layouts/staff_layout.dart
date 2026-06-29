import 'package:flutter/material.dart';
import 'package:petpal/core/constants/app_routes.dart';
import 'package:petpal/core/services/navigation_service.dart';
import 'package:petpal/features/auth/providers/auth_provider.dart';
import 'package:petpal/features/staff_portal/widgets/staff_navigation_bar.dart';
import 'package:petpal/features/staff_portal/widgets/staff_unread_notifier.dart';
import 'package:provider/provider.dart';

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
    final isRoot = _isRootRoute(currentRouteName);
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isRoot ? 16 : 0,
        leading: isRoot
            ? CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                child: Text(
                  _initial(user?.fullName),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : IconButton(
                tooltip: 'Quay lại',
                onPressed: () => NavigationService.goBack(context),
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: isRoot ? [StaffUnreadButton(staffId: user?.id)] : null,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 840
                  ? 32.0
                  : 16.0;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: StaffNavigationBar(currentRouteName: currentRouteName),
      ),
    );
  }

  static bool _isRootRoute(String routeName) {
    return routeName == AppRoutes.staffDashboard ||
        routeName == AppRoutes.staffSchedule ||
        routeName == AppRoutes.staffPetSearch ||
        routeName == AppRoutes.staffNotifications ||
        routeName == AppRoutes.staffMore;
  }

  static String _initial(String? name) {
    final trimmedName = name?.trim() ?? '';
    return trimmedName.isEmpty
        ? 'S'
        : trimmedName.characters.first.toUpperCase();
  }
}
