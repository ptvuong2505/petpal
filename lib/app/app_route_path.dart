import '../core/constants/app_routes.dart';

class AppRoutePath {
  const AppRoutePath._({
    required this.routeName,
    required this.location,
    required this.pageTitle,
    this.arguments,
  });

  factory AppRoutePath.home() {
    return AppRoutePath.byName(AppRoutes.home);
  }

  factory AppRoutePath.byName(String routeName, {Object? arguments}) {
    final route = AppRouteCatalog.findByName(routeName);
    return AppRoutePath._(
      routeName: route.name,
      location: route.location,
      pageTitle: route.title,
      arguments: arguments,
    );
  }

  factory AppRoutePath.byLocation(String location) {
    final route = AppRouteCatalog.findByLocation(location);
    return AppRoutePath._(
      routeName: route.name,
      location: route.location,
      pageTitle: route.title,
    );
  }

  final String routeName;
  final String location;
  final String pageTitle;
  final Object? arguments;

  bool get isHome => routeName == AppRoutes.home;
}

class AppRouteInfo {
  const AppRouteInfo({
    required this.name,
    required this.location,
    required this.title,
  });

  final String name;
  final String location;
  final String title;
}

class AppRouteCatalog {
  static const List<AppRouteInfo> routes = [
    AppRouteInfo(name: AppRoutes.home, location: '/', title: 'PetPal'),
    AppRouteInfo(name: AppRoutes.login, location: '/login', title: 'Login'),
    AppRouteInfo(
      name: AppRoutes.register,
      location: '/register',
      title: 'Register',
    ),
    AppRouteInfo(
      name: AppRoutes.forgotPassword,
      location: '/forgot-password',
      title: 'Forgot Password',
    ),
    AppRouteInfo(
      name: AppRoutes.userProfile,
      location: '/user-profile',
      title: 'User Profile',
    ),
    AppRouteInfo(
      name: AppRoutes.editUserProfile,
      location: '/user-profile/edit',
      title: 'Edit User Profile',
    ),
    AppRouteInfo(name: AppRoutes.petList, location: '/pets', title: 'Pet List'),
    AppRouteInfo(
      name: AppRoutes.petDetail,
      location: '/pets/detail',
      title: 'Pet Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.addPet,
      location: '/pets/add',
      title: 'Add Pet',
    ),
    AppRouteInfo(
      name: AppRoutes.editPet,
      location: '/pets/edit',
      title: 'Edit Pet',
    ),
    AppRouteInfo(
      name: AppRoutes.healthRecordList,
      location: '/health-records',
      title: 'Health Records',
    ),
    AppRouteInfo(
      name: AppRoutes.healthRecordDetail,
      location: '/health-records/detail',
      title: 'Health Record Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.bookingService,
      location: '/booking/service',
      title: 'Booking Service',
    ),
    AppRouteInfo(
      name: AppRoutes.bookingPet,
      location: '/booking/pet',
      title: 'Booking Pet',
    ),
    AppRouteInfo(
      name: AppRoutes.bookingTimeSlot,
      location: '/booking/time-slot',
      title: 'Booking Time Slot',
    ),
    AppRouteInfo(
      name: AppRoutes.bookingConfirm,
      location: '/booking/confirm',
      title: 'Booking Confirm',
    ),
    AppRouteInfo(
      name: AppRoutes.myBookings,
      location: '/bookings/my',
      title: 'My Bookings',
    ),
    AppRouteInfo(
      name: AppRoutes.bookingDetail,
      location: '/bookings/detail',
      title: 'Booking Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.timeSlotManagement,
      location: '/time-slots',
      title: 'Time Slot Management',
    ),
    AppRouteInfo(
      name: AppRoutes.createTimeSlot,
      location: '/time-slots/create',
      title: 'Create Time Slot',
    ),
    AppRouteInfo(
      name: AppRoutes.editTimeSlot,
      location: '/time-slots/edit',
      title: 'Edit Time Slot',
    ),
    AppRouteInfo(
      name: AppRoutes.reviewList,
      location: '/reviews',
      title: 'Danh sách đánh giá',
    ),
    AppRouteInfo(
      name: AppRoutes.reviewDetail,
      location: '/reviews/detail',
      title: 'Review Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.createReview,
      location: '/reviews/create',
      title: 'Đánh giá dịch vụ',
    ),
    AppRouteInfo(
      name: AppRoutes.myReviews,
      location: '/reviews/my',
      title: 'Đánh giá của tôi',
    ),
    AppRouteInfo(
      name: AppRoutes.staffDashboard,
      location: '/staff',
      title: 'Staff Dashboard',
    ),
    AppRouteInfo(
      name: AppRoutes.staffBookingList,
      location: '/staff/bookings',
      title: 'Staff Booking List',
    ),
    AppRouteInfo(
      name: AppRoutes.staffBookingDetail,
      location: '/staff/bookings/detail',
      title: 'Staff Booking Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.createExaminationResult,
      location: '/staff/examination-results/create',
      title: 'Create Examination Result',
    ),
    AppRouteInfo(
      name: AppRoutes.examinationResultDetail,
      location: '/staff/examination-results/detail',
      title: 'Examination Result Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.reminderList,
      location: '/reminders',
      title: 'Reminder List',
    ),
    AppRouteInfo(
      name: AppRoutes.createReminder,
      location: '/reminders/create',
      title: 'Create Reminder',
    ),
    AppRouteInfo(
      name: AppRoutes.editReminder,
      location: '/reminders/edit',
      title: 'Edit Reminder',
    ),
    AppRouteInfo(
      name: AppRoutes.adminDashboard,
      location: '/admin',
      title: 'Admin Dashboard',
    ),
    AppRouteInfo(
      name: AppRoutes.shopSetting,
      location: '/shop-setting',
      title: 'Shop Setting',
    ),
  ];

  static AppRouteInfo findByName(String routeName) {
    return routes.firstWhere(
      (route) => route.name == routeName,
      orElse: () => routes.first,
    );
  }

  static AppRouteInfo findByLocation(String location) {
    return routes.firstWhere(
      (route) => route.location == location,
      orElse: () => routes.first,
    );
  }
}
