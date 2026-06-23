import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/widgets/staff_status_badge.dart';

void main() {
  testWidgets('StaffStatusBadge exposes the status meaning to assistive tech', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StaffStatusBadge(status: 'pending')),
      ),
    );

    expect(find.bySemanticsLabel('Trạng thái: Đang chờ'), findsOneWidget);
  });
}
