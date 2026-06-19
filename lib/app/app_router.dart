import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../core/services/navigation_service.dart';
import '../features/admin_dashboard/pages/admin_dashboard_page.dart';
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
import '../features/time_slot/pages/create_time_slot_page.dart';
import '../features/time_slot/pages/edit_time_slot_page.dart';
import '../features/time_slot/pages/time_slot_management_page.dart';
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

    final pages = <Page>[
      MaterialPage(
        key: const ValueKey(AppRoutes.home),
        name: AppRoutes.home,
        child: _buildPageWithLayout(AppRoutes.home),
      ),
    ];

    if (!_currentPath.isHome) {
      pages.add(
        MaterialPage(
          key: ValueKey(_currentPath.routeName),
          name: _currentPath.location,
          child: _buildPageWithLayout(_currentPath.routeName),
        ),
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (page) {
        if (page.name == _currentPath.location) {
          goHome();
        }
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentPath = configuration;
    notifyListeners();
  }

  @override
  void goTo(String routeName, {Object? arguments}) {
    _currentPath = AppRoutePath.byName(routeName, arguments: arguments);
    notifyListeners();
  }

  void goHome() {
    _currentPath = AppRoutePath.home();
    notifyListeners();
  }

  Widget _buildPageWithLayout(String routeName) {
    final page = _buildPage(routeName, _currentPath.arguments);
    final path = AppRoutePath.byName(routeName);

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

  Widget _buildPage(String routeName, [Object? arguments]) {
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
        return HealthRecordDetailPage(record: arguments as HealthRecord?);
      case AppRoutes.bookingService:
        return const BookingServicePage();
      case AppRoutes.bookingPet:
        return const BookingPetPage();
      case AppRoutes.bookingTimeSlot:
        return const BookingTimeSlotPage();
      case AppRoutes.bookingConfirm:
        return const BookingConfirmPage();
      case AppRoutes.myBookings:
        return const MyBookingsPage();
      case AppRoutes.bookingDetail:
        return const BookingDetailPage();
      case AppRoutes.timeSlotManagement:
        return const TimeSlotManagementPage();
      case AppRoutes.createTimeSlot:
        return const CreateTimeSlotPage();
      case AppRoutes.editTimeSlot:
        return const EditTimeSlotPage();
      case AppRoutes.reviewList:
        return const ReviewListPage();
      case AppRoutes.reviewDetail:
        return const ReviewDetailPage();
      case AppRoutes.createReview:
        if (arguments is Review) {
          return CreateReviewPage(review: arguments);
        }
        return CreateReviewPage(bookingId: arguments as int?);
      case AppRoutes.myReviews:
        return const MyReviewsPage();
      case AppRoutes.staffDashboard:
        return const StaffDashboardPage();
      case AppRoutes.staffBookingList:
        return const StaffBookingListPage();
      case AppRoutes.staffBookingDetail:
        return const StaffBookingDetailPage();
      case AppRoutes.createExaminationResult:
        return const CreateExaminationResultPage();
      case AppRoutes.examinationResultDetail:
        return const ExaminationResultDetailPage();
      case AppRoutes.reminderList:
        return const ReminderListPage();
      case AppRoutes.createReminder:
        return const CreateReminderPage();
      case AppRoutes.editReminder:
        return const EditReminderPage();
      case AppRoutes.adminDashboard:
        return const AdminDashboardPage();
      case AppRoutes.shopSetting:
        return const ShopSettingPage();
      default:
        return const AppHomePage();
    }
  }
}
