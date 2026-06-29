import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../core/services/navigation_service.dart';
import '../features/admin_dashboard/pages/admin_booking_detail_page.dart';
import '../features/admin_dashboard/pages/admin_booking_list_page.dart';
import '../features/admin_dashboard/pages/admin_dashboard_page.dart';
import '../features/admin_dashboard/pages/admin_review_detail_page.dart';
import '../features/admin_dashboard/pages/admin_review_list_page.dart';
import '../features/admin_shift_management/pages/admin_assign_shift_page.dart';
import '../features/admin_shift_management/pages/admin_shift_calendar_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/booking/pages/booking_confirm_page.dart';
import '../features/booking/pages/booking_detail_page.dart';
import '../features/booking/pages/booking_pet_page.dart';
import '../features/booking/pages/booking_service_page.dart';
import '../features/booking/pages/booking_time_slot_page.dart';
import '../features/booking/pages/my_bookings_page.dart';
import '../features/health_record/models/health_record.dart';
import '../features/health_record/pages/health_record_detail_page.dart';
import '../features/health_record/pages/health_record_list_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/pet_profile/pages/add_pet_page.dart';
import '../features/pet_profile/pages/edit_pet_page.dart';
import '../features/pet_profile/pages/pet_detail_page.dart';
import '../features/pet_profile/pages/pet_list_page.dart';
import '../features/payment/pages/payment_page.dart';
import '../features/reminder/pages/create_reminder_page.dart';
import '../features/reminder/pages/edit_reminder_page.dart';
import '../features/reminder/pages/reminder_list_page.dart';
import '../features/review/models/review.dart';
import '../features/review/pages/create_review_page.dart';
import '../features/review/pages/my_reviews_page.dart';
import '../features/review/pages/review_detail_page.dart';
import '../features/review/pages/review_list_page.dart';
import '../features/shop_setting/pages/shop_setting_page.dart';
import '../features/staff_examination/pages/create_examination_result_page.dart';
import '../features/staff_examination/pages/examination_result_detail_page.dart';
import '../features/staff_examination/pages/staff_booking_detail_page.dart';
import '../features/staff_examination/pages/staff_booking_list_page.dart';
import '../features/staff_examination/pages/staff_dashboard_page.dart';
import '../features/staff_notifications/pages/staff_notifications_page.dart';
import '../features/staff_portal/pages/staff_more_page.dart';
import '../features/staff_pet_search/pages/staff_pet_medical_profile_page.dart';
import '../features/staff_pet_search/pages/staff_pet_search_page.dart';
import '../features/staff_profile/pages/edit_staff_profile_page.dart';
import '../features/staff_profile/pages/staff_profile_page.dart';
import '../features/staff_schedule/pages/staff_schedule_page.dart';
import '../features/staff_schedule/pages/staff_shift_request_page.dart';
import '../features/staff_statistics/pages/staff_statistics_page.dart';
import '../features/user_profile/pages/edit_user_profile_page.dart';
import '../features/user_profile/pages/user_profile_page.dart';
import '../shared/layouts/admin_layout.dart';
import '../shared/layouts/staff_layout.dart';
import '../shared/layouts/user_layout.dart';
import '../shared/widgets/app_page.dart';
import 'app_route_path.dart';

class AppRouter extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath>
    implements AppNavigationController {
  AppRoutePath _currentPath = AppRoutePath.home();
  final List<AppRoutePath> _history = [];
  AuthProvider? _authProvider;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _authProvider?.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  AppRoutePath get currentConfiguration => _currentPath;

  void setAuthProvider(AuthProvider authProvider) {
    if (_authProvider == authProvider) return;

    _authProvider?.removeListener(notifyListeners);
    _authProvider = authProvider;
    _authProvider?.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) {
    final auth = _authProvider;

    if (auth == null || auth.isCheckingLogin) {
      return Navigator(
        key: navigatorKey,
        pages: const [
          MaterialPage(
            child: AppPage(
              title: 'PetPal',
              message: 'Đang kiểm tra đăng nhập...',
            ),
          ),
        ],
        onDidRemovePage: (page) {},
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: _buildNavigatorPages(),
      // ignore: deprecated_member_use
      onPopPage: handlePopPage,
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _history.clear();
    _currentPath = configuration;
    notifyListeners();
  }

  @override
  void goTo(
    String routeName, {
    Object? arguments,
    Map<String, String> queryParameters = const {},
  }) {
    final nextPath = AppRoutePath.byName(
      routeName,
      arguments: arguments,
      queryParameters: queryParameters,
    );

    if (nextPath.isHome) {
      goHome();
      return;
    }

    if (nextPath.location == _currentPath.location) {
      _currentPath = nextPath;
      notifyListeners();
      return;
    }

    _history.add(_currentPath);
    _currentPath = nextPath;
    notifyListeners();
  }

  void goHome() {
    _history.clear();
    _currentPath = AppRoutePath.home();
    notifyListeners();
  }

  @override
  void goBack() {
    _currentPath = _history.isEmpty
        ? AppRoutePath.home()
        : _history.removeLast();
    notifyListeners();
  }

  bool handlePopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (route.settings.name == _currentPath.location) {
      goBack();
    }
    return true;
  }

  List<Page<dynamic>> _buildNavigatorPages() {
    final paths = <AppRoutePath>[AppRoutePath.home()];

    for (final path in _history) {
      if (path.isHome) {
        continue;
      }
      paths.add(path);
    }

    if (!_currentPath.isHome) {
      paths.add(_currentPath);
    }

    return [
      for (var index = 0; index < paths.length; index++)
        MaterialPage(
          key: ValueKey('${paths[index].location}-$index'),
          name: paths[index].location,
          child: _buildPageWithLayout(paths[index]),
        ),
    ];
  }

  Widget _buildPageWithLayout(AppRoutePath path) {
    final routeName = path.routeName;
    final page = _buildPage(path);

    if (AppRoutes.isAuthRoute(routeName)) {
      return page;
    }

    if (AppRoutes.isAdminRoute(routeName)) {
      return AdminLayout(
        title: path.pageTitle,
        currentRouteName: routeName,
        child: page,
      );
    }

    if (AppRoutes.isStaffRoute(routeName)) {
      return StaffLayout(
        title: path.pageTitle,
        currentRouteName: routeName,
        child: page,
      );
    }

    return UserLayout(
      title: path.pageTitle,
      currentRouteName: routeName,
      child: page,
    );
  }

  Widget _buildPage(AppRoutePath path) {
    final routeName = path.routeName;
    switch (routeName) {
      case AppRoutes.login:
        return const LoginPage();
      case AppRoutes.register:
        return const RegisterPage();
      case AppRoutes.forgotPassword:
        return const ForgotPasswordPage();
      case AppRoutes.userProfile:
        return const UserProfilePage();
      case AppRoutes.editUserProfile:
        return const EditUserProfilePage();
      case AppRoutes.petList:
        return const PetListPage();
      case AppRoutes.petDetail:
        return const PetDetailPage();
      case AppRoutes.addPet:
        return const AddPetPage();
      case AppRoutes.editPet:
        return const EditPetPage();
      case AppRoutes.healthRecordList:
        return const HealthRecordListPage();
      case AppRoutes.healthRecordDetail:
        final record = path.arguments as HealthRecord?;
        return HealthRecordDetailPage(record: record);
      case AppRoutes.bookingService:
        return const BookingServicePage();
      case AppRoutes.bookingPet:
        return const BookingPetPage();
      case AppRoutes.bookingTimeSlot:
        return const BookingTimeSlotPage();
      case AppRoutes.bookingConfirm:
        return const BookingConfirmPage();
      case AppRoutes.payment:
        final bookingId = path.bookingId;
        if (bookingId == null) {
          return const AppPage(
            title: 'Thanh toán',
            message: 'Thiếu hoặc sai bookingId.',
          );
        }
        return PaymentPage(bookingId: bookingId);
      case AppRoutes.myBookings:
        return const MyBookingsPage();
      case AppRoutes.bookingDetail:
        final bookingId = path.bookingId;
        if (bookingId == null) {
          return const AppPage(
            title: 'Chi tiết lịch hẹn',
            message: 'Thiếu mã đặt lịch.',
          );
        }
        return BookingDetailPage(bookingId: bookingId);
      case AppRoutes.reviewList:
        return const ReviewListPage();
      case AppRoutes.reviewDetail:
        return const ReviewDetailPage();
      case AppRoutes.createReview:
        final arg = path.arguments;
        if (arg is Review) {
          return CreateReviewPage(review: arg);
        }
        final bId = arg is int ? arg : path.bookingId;
        return CreateReviewPage(bookingId: bId);
      case AppRoutes.myReviews:
        return const MyReviewsPage();
      case AppRoutes.staffDashboard:
        return const StaffDashboardPage();
      case AppRoutes.staffBookingList:
        return const StaffBookingListPage();
      case AppRoutes.staffBookingDetail:
        final bookingId = path.bookingId;
        if (bookingId == null) {
          return const AppPage(
            title: 'Staff Booking Detail',
            message: 'Thiếu hoặc sai bookingId.',
          );
        }
        return StaffBookingDetailPage(bookingId: bookingId);
      case AppRoutes.createExaminationResult:
        final bookingId = path.bookingId;
        if (bookingId == null) {
          return const AppPage(
            title: 'Create Examination Result',
            message: 'Thiếu hoặc sai bookingId.',
          );
        }
        return CreateExaminationResultPage(bookingId: bookingId);
      case AppRoutes.examinationResultDetail:
        final resultId = path.resultId;
        if (resultId == null) {
          return const AppPage(
            title: 'Examination Result Detail',
            message: 'Thiếu hoặc sai resultId.',
          );
        }
        return ExaminationResultDetailPage(resultId: resultId);
      case AppRoutes.staffSchedule:
        return const StaffSchedulePage();
      case AppRoutes.staffShiftRequest:
        return const StaffShiftRequestPage();
      case AppRoutes.staffPetSearch:
        return const StaffPetSearchPage();
      case AppRoutes.staffPetDetail:
        final petId = path.petId;
        if (petId == null) {
          return const AppPage(
            title: 'Pet Medical Profile',
            message: 'Thiếu hoặc sai petId.',
          );
        }
        return StaffPetMedicalProfilePage(petId: petId);
      case AppRoutes.staffNotifications:
        return const StaffNotificationsPage();
      case AppRoutes.staffStatistics:
        return const StaffStatisticsPage();
      case AppRoutes.staffProfile:
        return const StaffProfilePage();
      case AppRoutes.editStaffProfile:
        return const EditStaffProfilePage();
      case AppRoutes.staffMore:
        return const StaffMorePage();
      case AppRoutes.reminderList:
        return const ReminderListPage();
      case AppRoutes.createReminder:
        return const CreateReminderPage();
      case AppRoutes.editReminder:
        return const EditReminderPage();
      case AppRoutes.adminDashboard:
        return const AdminDashboardPage();
      case AppRoutes.adminBookingList:
        return const AdminBookingListPage();
      case AppRoutes.adminBookingDetail:
        final bookingId = path.bookingId;
        if (bookingId == null) {
          return const AppPage(
            title: 'Booking Detail',
            message: 'Thiếu hoặc sai bookingId.',
          );
        }
        return AdminBookingDetailPage(bookingId: bookingId);
      case AppRoutes.adminReviewList:
        return const AdminReviewListPage();
      case AppRoutes.adminReviewDetail:
        final reviewId = path.reviewId;
        if (reviewId == null) {
          return const AppPage(
            title: 'Review Detail',
            message: 'Thiếu hoặc sai reviewId.',
          );
        }
        return AdminReviewDetailPage(reviewId: reviewId);
      case AppRoutes.adminShiftCalendar:
        return const AdminShiftCalendarPage();
      case AppRoutes.adminAssignShift:
        return const AdminAssignShiftPage();
      case AppRoutes.shopSetting:
        return const ShopSettingPage();
      default:
        return const AppHomePage();
    }
  }
}
