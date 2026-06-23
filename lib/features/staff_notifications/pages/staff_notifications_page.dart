import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../../staff_portal/widgets/staff_unread_notifier.dart';

class StaffNotificationsPage extends StatefulWidget {
  const StaffNotificationsPage({super.key});

  @override
  State<StaffNotificationsPage> createState() => _StaffNotificationsPageState();
}

class _StaffNotificationsPageState extends State<StaffNotificationsPage> {
  final _dao = StaffPortalDao();
  final Set<String> _markingRead = {};
  List<Map<String, Object?>> _items = [];
  bool _unreadOnly = false;
  bool _loading = true;
  String? _errorMessage;

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final items = await _dao.notifications(id);
      if (mounted) {
        setState(() => _items = items);
        staffUnreadNotifier.replaceItems(items);
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Không thể tải thông báo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(Map<String, Object?> item) async {
    final key = '${item['notification_key'] ?? ''}';
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null ||
        key.isEmpty ||
        item['is_read'] == true ||
        _markingRead.contains(key)) {
      return;
    }
    setState(() => _markingRead.add(key));
    try {
      await _dao.markRead(id, key);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (value) => value['notification_key'] == key
                  ? <String, Object?>{...value, 'is_read': true}
                  : value,
            )
            .toList();
      });
      staffUnreadNotifier.markRead();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đánh dấu đã đọc.')),
        );
      }
    } finally {
      if (mounted) setState(() => _markingRead.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _load,
      child: SafeArea(top: false, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_loading && _items.isEmpty) {
      return const StaffLoadingState(skeleton: true);
    }
    if (_errorMessage != null && _items.isEmpty) {
      return StaffErrorState(message: _errorMessage!, onRetry: _load);
    }
    final items = _unreadOnly
        ? _items.where((item) => item['is_read'] != true).toList()
        : _items;
    final unread = _items.where((item) => item['is_read'] != true).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Chưa đọc'),
                selected: _unreadOnly,
                onSelected: (value) => setState(() => _unreadOnly = value),
              ),
              const Spacer(),
              Text('$unread chưa đọc'),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? StaffEmptyState(
                  icon: Icons.notifications_none_outlined,
                  message: _unreadOnly
                      ? 'Bạn đã đọc tất cả thông báo.'
                      : 'Không có thông báo.',
                  onRetry: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _NotificationCard(
                      item: items[index],
                      isMarkingRead: _markingRead.contains(
                        '${items[index]['notification_key'] ?? ''}',
                      ),
                      onTap: () => _markRead(items[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.isMarkingRead,
    required this.onTap,
  });

  final Map<String, Object?> item;
  final bool isMarkingRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final read = item['is_read'] == true;
    final cancelled = item['status'] == 'cancelled';
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: read ? null : colorScheme.primaryContainer,
      child: ListTile(
        enabled: !isMarkingRead,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: read
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.primary,
              foregroundColor: read
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onPrimary,
              child: Icon(
                cancelled
                    ? Icons.cancel_outlined
                    : Icons.notifications_active_outlined,
              ),
            ),
            if (!read)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          '${item['title'] ?? 'Thông báo'}',
          style: TextStyle(
            fontWeight: read ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${item['message'] ?? ''}\n${_formatRelativeTime(item['event_time'])}',
        ),
        isThreeLine: true,
        trailing: isMarkingRead
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : read
            ? const Icon(Icons.done_all, semanticLabel: 'Đã đọc')
            : const Icon(
                Icons.mark_email_unread_outlined,
                semanticLabel: 'Chưa đọc',
              ),
        onTap: onTap,
      ),
    );
  }

  String _formatRelativeTime(Object? value) {
    final raw = '$value'.trim();
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw.isEmpty ? 'Chưa cập nhật thời gian' : raw;
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays == 1) return 'Hôm qua';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
