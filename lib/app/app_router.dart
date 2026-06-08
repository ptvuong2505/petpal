import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/services/navigation_service.dart';
import '../features/admin_dashboard/pages/admin_dashboard_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/booking/pages/booking_confirm_page.dart';
import '../features/booking/pages/booking_detail_page.dart';
import '../features/booking/pages/booking_pet_page.dart';
import '../features/booking/pages/booking_service_page.dart';
import '../features/booking/pages/booking_time_slot_page.dart';
import '../features/booking/pages/my_bookings_page.dart';
import '../features/health_record/pages/health_record_detail_page.dart';
import '../features/health_record/pages/health_record_list_page.dart';
import '../features/pet_profile/pages/add_pet_page.dart';
import '../features/pet_profile/pages/edit_pet_page.dart';
import '../features/pet_profile/pages/pet_detail_page.dart';
import '../features/pet_profile/pages/pet_list_page.dart';
import '../features/reminder/pages/create_reminder_page.dart';
import '../features/reminder/pages/edit_reminder_page.dart';
import '../features/reminder/pages/reminder_list_page.dart';
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
import '../shared/widgets/app_page.dart';
import 'app_route_path.dart';

class AppRouter extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath>
    implements AppNavigationController {
  AppRoutePath _currentPath = AppRoutePath.home();

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration => _currentPath;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey(AppRoutes.home),
          name: AppRoutes.home,
          child: AppHomePage(onOpen: goTo),
        ),
        if (!_currentPath.isHome)
          MaterialPage(
            key: ValueKey(_currentPath.routeName),
            name: _currentPath.location,
            child: _buildPage(_currentPath.routeName),
          ),
      ],
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
  }

  @override
  void goTo(String routeName) {
    _currentPath = AppRoutePath.byName(routeName);
    notifyListeners();
  }

  void goHome() {
    _currentPath = AppRoutePath.home();
    notifyListeners();
  }

  Widget _buildPage(String routeName) {
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
        return const HealthRecordDetailPage();
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
        return const CreateReviewPage();
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
        return AppHomePage(onOpen: goTo);
    }
  }
}

class AppHomePage extends StatelessWidget {
  const AppHomePage({required this.onOpen, super.key});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'PetPal',
      message: 'Welcome to PetPal',
      actions: [
        PageAction(label: 'Login', routeName: AppRoutes.login),
        PageAction(label: 'Pets', routeName: AppRoutes.petList),
        PageAction(label: 'Booking', routeName: AppRoutes.bookingService),
        PageAction(label: 'Staff', routeName: AppRoutes.staffDashboard),
        PageAction(label: 'Admin', routeName: AppRoutes.adminDashboard),
      ],
      onAction: onOpen,
    );
  }
}
