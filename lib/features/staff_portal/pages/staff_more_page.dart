import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/staff_access_guard.dart';

class StaffMorePage extends StatefulWidget {
  const StaffMorePage({super.key});

  @override
  State<StaffMorePage> createState() => _StaffMorePageState();
}

class _StaffMorePageState extends State<StaffMorePage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Thống kê'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  NavigationService.goTo(context, AppRoutes.staffStatistics),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Hồ sơ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  NavigationService.goTo(context, AppRoutes.staffProfile),
            ),
            const Divider(),
            ListTile(
              enabled: !_isLoggingOut,
              leading: _isLoggingOut
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, color: Colors.red),
              title: Text(
                _isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất',
                style: TextStyle(
                  color: _isLoggingOut
                      ? null
                      : Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: _isLoggingOut ? null : _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất Staff?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để tiếp tục làm việc.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _logout();
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    NavigationService.goTo(context, AppRoutes.login);
  }
}
