import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petpal/app/app.dart';
import 'package:petpal/app/app_route_parser.dart';

void main() {
  testWidgets('PetPal app opens home and navigates to login', (tester) async {
    await tester.pumpWidget(const PetPalApp());
    await tester.pump();

    expect(find.text('PetPal'), findsWidgets);
    expect(find.text('Welcome to PetPal'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Login Page'), findsOneWidget);
  });

  test('AppRouteParser parses a named route path', () async {
    final parser = AppRouteParser();
    final path = await parser.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/login')),
    );

    expect(path.location, '/login');
    expect(path.pageTitle, 'Login');
  });
}
