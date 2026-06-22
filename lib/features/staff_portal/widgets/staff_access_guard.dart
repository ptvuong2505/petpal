import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'staff_access_policy.dart';
import 'staff_state_view.dart';

class StaffAccessGuard extends StatefulWidget {
  const StaffAccessGuard({required this.child, this.onAllowed, super.key});

  final Widget child;
  final VoidCallback? onAllowed;

  static bool isAuthorized(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return staffAccessFor(
          isCheckingLogin: auth.isCheckingLogin,
          isLoggedIn: auth.isLoggedIn,
          role: auth.currentRole,
        ) ==
        StaffAccess.allowed;
  }

  @override
  State<StaffAccessGuard> createState() => _StaffAccessGuardState();
}

class _StaffAccessGuardState extends State<StaffAccessGuard> {
  bool _sentToLogin = false;
  bool _notifiedAllowed = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final access = staffAccessFor(
      isCheckingLogin: auth.isCheckingLogin,
      isLoggedIn: auth.isLoggedIn,
      role: auth.currentRole,
    );

    switch (access) {
      case StaffAccess.loading:
        return const StaffLoadingState();
      case StaffAccess.loginRequired:
        _goToLogin();
        return const StaffLoadingState();
      case StaffAccess.denied:
        return _AccessDenied(role: auth.currentRole);
      case StaffAccess.allowed:
        _notifyAllowed();
        return widget.child;
    }
  }

  void _goToLogin() {
    if (_sentToLogin) return;
    _sentToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NavigationService.goTo(context, AppRoutes.login);
    });
  }

  void _notifyAllowed() {
    if (_notifiedAllowed || widget.onAllowed == null) return;
    _notifiedAllowed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onAllowed?.call();
    });
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied({required this.role});

  final String? role;

  @override
  Widget build(BuildContext context) {
    return StaffEmptyState(
      icon: Icons.lock_outline,
      message: 'Bạn không có quyền truy cập khu vực Staff.',
      retryLabel: 'Về màn hình phù hợp',
      onRetry: () => NavigationService.goTo(
        context,
        AppRoutes.loginDestinationForRole(role),
      ),
    );
  }
}
