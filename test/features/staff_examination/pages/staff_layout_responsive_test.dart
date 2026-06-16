import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/core/constants/app_routes.dart';
import 'package:petpal/features/auth/data/auth_dao.dart';
import 'package:petpal/features/auth/models/user.dart';
import 'package:petpal/features/auth/providers/auth_provider.dart';
import 'package:petpal/features/auth/repositories/auth_repository.dart';
import 'package:petpal/shared/layouts/app_layout.dart';
import 'package:petpal/shared/layouts/staff_layout.dart';
import 'package:petpal/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

void main() {
  late AuthProvider auth;

  setUp(() {
    auth = AuthProvider(repository: AuthRepository(dao: AuthDao()))
      ..currentUser = const User(
        id: 3,
        fullName: 'Staff',
        email: 'staff@gmail.com',
        role: 'staff',
      );
  });

  testWidgets('staff layout fits long title at 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: StaffLayout(
            title: 'Create Examination Result',
            currentRouteName: AppRoutes.createExaminationResult,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('app bar fits long staff title at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppLayout(
          title: 'Create Examination Result',
          showBottomNav: false,
          constrainTitle: true,
          child: SizedBox.expand(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('staff bottom navigation fits at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentRouteName: AppRoutes.createExaminationResult,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('staff layout and navigation fit at 320x568', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: StaffLayout(
            title: 'Create Examination Result',
            currentRouteName: AppRoutes.createExaminationResult,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
