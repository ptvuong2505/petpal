import '../core/constants/app_routes.dart';

class AppRoutePath {
  const AppRoutePath._({
    required this.routeName,
    required this.location,
    required this.pageTitle,
    this.arguments,
    this.queryParameters = const {},
  });

  factory AppRoutePath.home() {
    return AppRoutePath.byName(AppRoutes.home);
  }

  factory AppRoutePath.byName(
    String routeName, {
    Object? arguments,
    Map<String, String> queryParameters = const {},
  }) {
    final route = AppRouteCatalog.findByName(routeName);
    final copiedQueryParameters = Map<String, String>.unmodifiable(
      Map<String, String>.of(queryParameters),
    );
    final uri = Uri(
      path: route.location,
      queryParameters: copiedQueryParameters.isEmpty
          ? null
          : copiedQueryParameters,
    );
    return AppRoutePath._(
      routeName: route.name,
      location: uri.toString(),
      pageTitle: route.title,
      arguments: arguments,
      queryParameters: copiedQueryParameters,
    );
  }

  factory AppRoutePath.byLocation(String location) {
    final uri = Uri.parse(location);
    final route = AppRouteCatalog.findByLocation(uri.path);
    final queryParameters = Map<String, String>.unmodifiable(
      Map<String, String>.of(uri.queryParameters),
    );
    return AppRoutePath._(
      routeName: route.name,
      location: route.name == AppRoutes.home ? route.location : uri.toString(),
      pageTitle: route.title,
      queryParameters: queryParameters,
    );
  }

  final String routeName;
  final String location;
  final String pageTitle;
  final Object? arguments;
  final Map<String, String> queryParameters;

  bool get isHome => routeName == AppRoutes.home;

  int? get bookingId => int.tryParse(queryParameters['bookingId'] ?? '');
  int? get resultId => int.tryParse(queryParameters['resultId'] ?? '');
  int? get petId => int.tryParse(queryParameters['petId'] ?? '');
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
      location: '/staff/dashboard',
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
      location: '/staff/examination/result',
      title: 'Examination Result Detail',
    ),
    AppRouteInfo(
      name: AppRoutes.staffSchedule,
      location: '/staff/schedule',
      title: 'Staff Schedule',
    ),
    AppRouteInfo(
      name: AppRoutes.staffShiftRequest,
      location: '/staff/schedule/request',
      title: 'Shift Request',
    ),
    AppRouteInfo(
      name: AppRoutes.staffPetSearch,
      location: '/staff/pets/search',
      title: 'Pet Search',
    ),
    AppRouteInfo(
      name: AppRoutes.staffPetDetail,
      location: '/staff/pets/detail',
      title: 'Pet Medical Profile',
    ),
    AppRouteInfo(
      name: AppRoutes.staffNotifications,
      location: '/staff/notifications',
      title: 'Staff Notifications',
    ),
    AppRouteInfo(
      name: AppRoutes.staffStatistics,
      location: '/staff/statistics',
      title: 'Staff Statistics',
    ),
    AppRouteInfo(
      name: AppRoutes.staffProfile,
      location: '/staff/profile',
      title: 'Staff Profile',
    ),
    AppRouteInfo(
      name: AppRoutes.editStaffProfile,
      location: '/staff/profile/edit',
      title: 'Edit Staff Profile',
    ),
    AppRouteInfo(
      name: AppRoutes.staffMore,
      location: '/staff/more',
      title: 'More',
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
