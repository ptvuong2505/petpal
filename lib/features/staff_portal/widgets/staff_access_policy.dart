enum StaffAccess { loading, loginRequired, denied, allowed }

StaffAccess staffAccessFor({
  required bool isCheckingLogin,
  required bool isLoggedIn,
  required String? role,
}) {
  if (isCheckingLogin) return StaffAccess.loading;
  if (!isLoggedIn) return StaffAccess.loginRequired;
  return role == 'staff' ? StaffAccess.allowed : StaffAccess.denied;
}
