import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/staff_access_guard.dart';
import '../widgets/staff_content.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const StaffSectionHeader(title: 'Công việc'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                minTileHeight: 64,
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Thống kê'),
                subtitle: const Text('Theo dõi tiến độ và đánh giá'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    NavigationService.goTo(context, AppRoutes.staffStatistics),
              ),
            ),
            const SizedBox(height: 24),
            const StaffSectionHeader(title: 'Tài khoản'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                minTileHeight: 64,
                leading: const Icon(Icons.person_outline),
                title: const Text('Hồ sơ cá nhân'),
                subtitle: const Text('Chuyên môn và chứng chỉ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    NavigationService.goTo(context, AppRoutes.staffProfile),
              ),
            ),
            const SizedBox(height: 24),
            const StaffSectionHeader(title: 'Phiên làm việc'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                minTileHeight: 64,
                enabled: !_isLoggingOut,
                leading: _isLoggingOut
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                title: Text(_isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isLoggingOut ? null : _confirmLogout,
              ),
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
