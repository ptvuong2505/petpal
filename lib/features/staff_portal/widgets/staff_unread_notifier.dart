import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../data/staff_portal_dao.dart';

final staffUnreadNotifier = StaffUnreadNotifier();

class StaffUnreadNotifier extends ChangeNotifier {
  StaffUnreadNotifier({StaffPortalDao? dao}) : _dao = dao ?? StaffPortalDao();

  final StaffPortalDao _dao;
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  String get displayCount => _unreadCount > 99 ? '99+' : '$_unreadCount';

  void replaceItems(Iterable<Map<String, Object?>> items) {
    final unread = items.where((item) => item['is_read'] != true).length;
    if (_unreadCount == unread) return;
    _unreadCount = unread;
    notifyListeners();
  }

  void markRead() {
    if (_unreadCount == 0) return;
    _unreadCount--;
    notifyListeners();
  }

  Future<void> refresh(int staffId) async {
    final items = await _dao.notifications(staffId);
    replaceItems(items);
  }
}

class StaffUnreadButton extends StatefulWidget {
  const StaffUnreadButton({required this.staffId, super.key});

  final int? staffId;

  @override
  State<StaffUnreadButton> createState() => _StaffUnreadButtonState();
}

class _StaffUnreadButtonState extends State<StaffUnreadButton>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    staffUnreadNotifier.addListener(_onUnreadChanged);
    _refresh();
  }

  @override
  void didUpdateWidget(covariant StaffUnreadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staffId != widget.staffId) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    staffUnreadNotifier.removeListener(_onUnreadChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _onUnreadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    final staffId = widget.staffId;
    if (staffId == null) return;
    try {
      await staffUnreadNotifier.refresh(staffId);
    } catch (_) {
      // The notifications screen owns its visible error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = staffUnreadNotifier.unreadCount;
    return IconButton(
      tooltip: unread == 0
          ? 'Thông báo'
          : 'Thông báo, ${staffUnreadNotifier.displayCount} chưa đọc',
      onPressed: () =>
          NavigationService.goTo(context, AppRoutes.staffNotifications),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (unread > 0)
            Positioned(
              top: -7,
              right: -10,
              child: Semantics(
                label: '${staffUnreadNotifier.displayCount} thông báo chưa đọc',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    staffUnreadNotifier.displayCount,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
