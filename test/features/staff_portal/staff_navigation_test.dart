import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/auth/data/auth_dao.dart';
import 'package:petpal/features/auth/models/user.dart';
import 'package:petpal/features/auth/providers/auth_provider.dart';
import 'package:petpal/features/auth/repositories/auth_repository.dart';
import 'package:petpal/shared/layouts/staff_layout.dart';
import 'package:provider/provider.dart';

void main() {
  group('StaffLayout navigation', () {
    testWidgets('keeps the Staff destination active for child routes', (
      tester,
    ) async {
      final cases = <({String route, int destination})>[
        (route: 'staffBookingDetail', destination: 0),
        (route: 'createExaminationResult', destination: 0),
        (route: 'examinationResultDetail', destination: 0),
        (route: 'staffShiftRequest', destination: 1),
        (route: 'staffPetDetail', destination: 2),
        (route: 'staffStatistics', destination: 4),
        (route: 'editStaffProfile', destination: 4),
      ];

      for (final testCase in cases) {
        await tester.pumpWidget(_staffShell(testCase.route));

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          testCase.destination,
          reason: '${testCase.route} must keep its parent Staff tab active',
        );
      }
    });
  });
}

Widget _staffShell(String currentRouteName) {
  final auth = AuthProvider(repository: AuthRepository(dao: AuthDao()))
    ..isCheckingLogin = false
    ..currentUser = const User(
      id: 1,
      fullName: 'Staff Test',
      email: 'staff@example.com',
      role: 'staff',
    );

  return ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp(
      home: StaffLayout(
        title: 'Staff',
        currentRouteName: currentRouteName,
        child: const SizedBox(),
      ),
    ),
  );
}
