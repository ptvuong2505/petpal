import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_portal/widgets/staff_access_policy.dart';

void main() {
  group('staffAccessFor', () {
    test('waits while the saved session is being restored', () {
      expect(
        staffAccessFor(isCheckingLogin: true, isLoggedIn: false, role: null),
        StaffAccess.loading,
      );
    });

    test('redirects an unauthenticated visitor to login', () {
      expect(
        staffAccessFor(isCheckingLogin: false, isLoggedIn: false, role: null),
        StaffAccess.loginRequired,
      );
    });

    test('denies a signed-in non-staff role', () {
      expect(
        staffAccessFor(isCheckingLogin: false, isLoggedIn: true, role: 'user'),
        StaffAccess.denied,
      );
    });

    test('allows a signed-in staff role', () {
      expect(
        staffAccessFor(isCheckingLogin: false, isLoggedIn: true, role: 'staff'),
        StaffAccess.allowed,
      );
    });
  });
}
