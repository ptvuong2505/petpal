import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_portal/widgets/staff_unread_notifier.dart';

void main() {
  test('formats a large unread count and updates it after a read', () {
    final notifier = StaffUnreadNotifier();
    final items = List<Map<String, Object?>>.generate(
      100,
      (index) => {'notification_key': '$index', 'is_read': false},
    );

    notifier.replaceItems(items);
    expect(notifier.unreadCount, 100);
    expect(notifier.displayCount, '99+');

    notifier.markRead();
    expect(notifier.unreadCount, 99);
    expect(notifier.displayCount, '99');
  });
}
