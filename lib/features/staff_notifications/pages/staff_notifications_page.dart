import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffNotificationsPage extends StatefulWidget {
  const StaffNotificationsPage({super.key});
  @override
  State<StaffNotificationsPage> createState() => _StaffNotificationsPageState();
}

class _StaffNotificationsPageState extends State<StaffNotificationsPage> {
  final _dao = StaffPortalDao();
  List<Map<String, Object?>> _items = [];
  bool _unreadOnly = false;
  bool _loading = true;
  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final items = await _dao.notifications(id);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _unreadOnly
        ? _items.where((e) => e['is_read'] != true).toList()
        : _items;
    return Column(
      children: [
        Row(
          children: [
            FilterChip(
              label: const Text('Chưa đọc'),
              selected: _unreadOnly,
              onSelected: (value) => setState(() => _unreadOnly = value),
            ),
            const Spacer(),
            Text(
              '${_items.where((e) => e['is_read'] != true).length} chưa đọc',
            ),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: items.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Không có thông báo.')),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final read = item['is_read'] == true;
                            return Card(
                              color: read
                                  ? null
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              child: ListTile(
                                leading: Icon(
                                  '${item['status']}' == 'cancelled'
                                      ? Icons.cancel_outlined
                                      : Icons.notifications_active_outlined,
                                ),
                                title: Text('${item['title']}'),
                                subtitle: Text(
                                  '${item['message']}\n${item['event_time'] ?? ''}',
                                ),
                                isThreeLine: true,
                                onTap: () async {
                                  final id = context
                                      .read<AuthProvider>()
                                      .currentUser
                                      ?.id;
                                  if (id != null) {
                                    await _dao.markRead(
                                      id,
                                      '${item['notification_key']}',
                                    );
                                  }
                                  await _load();
                                },
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
