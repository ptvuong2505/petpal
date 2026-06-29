class AppRoutes {
  static const String home = 'home';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String userProfile = 'userProfile';
  static const String editUserProfile = 'editUserProfile';
  static const String petList = 'petList';
  static const String petDetail = 'petDetail';
  static const String addPet = 'addPet';
  static const String editPet = 'editPet';
  static const String healthRecordList = 'healthRecordList';
  static const String healthRecordDetail = 'healthRecordDetail';
  static const String bookingService = 'bookingService';
  static const String bookingPet = 'bookingPet';
  static const String bookingTimeSlot = 'bookingTimeSlot';
  static const String bookingConfirm = 'bookingConfirm';
  static const String payment = 'payment';
  static const String myBookings = 'myBookings';
  static const String bookingDetail = 'bookingDetail';
  static const String reviewList = 'reviewList';
  static const String reviewDetail = 'reviewDetail';
  static const String createReview = 'createReview';
  static const String myReviews = 'myReviews';
  static const String staffDashboard = 'staffDashboard';
  static const String staffBookingList = 'staffBookingList';
  static const String staffBookingDetail = 'staffBookingDetail';
  static const String createExaminationResult = 'createExaminationResult';
  static const String examinationResultDetail = 'examinationResultDetail';
  static const String staffSchedule = 'staffSchedule';
  static const String staffShiftRequest = 'staffShiftRequest';
  static const String staffPetSearch = 'staffPetSearch';
  static const String staffPetDetail = 'staffPetDetail';
  static const String staffNotifications = 'staffNotifications';
  static const String staffStatistics = 'staffStatistics';
  static const String staffProfile = 'staffProfile';
  static const String editStaffProfile = 'editStaffProfile';
  static const String staffMore = 'staffMore';
  static const String reminderList = 'reminderList';
  static const String createReminder = 'createReminder';
  static const String editReminder = 'editReminder';
  static const String adminDashboard = 'adminDashboard';
  static const String adminBookingList = 'adminBookingList';
  static const String adminBookingDetail = 'adminBookingDetail';
  static const String adminReviewList = 'adminReviewList';
  static const String adminReviewDetail = 'adminReviewDetail';
  static const String adminShiftCalendar = 'adminShiftCalendar';
  static const String adminAssignShift = 'adminAssignShift';
  static const String shopSetting = 'shopSetting';

  static bool isAuthRoute(String routeName) {
    switch (routeName) {
      case login:
      case register:
      case forgotPassword:
        return true;
      default:
        return false;
    }
  }

  static bool isUserRoute(String routeName) {
    switch (routeName) {
      case home:
      case userProfile:
      case editUserProfile:
      case petList:
      case petDetail:
      case addPet:
      case editPet:
      case healthRecordList:
      case healthRecordDetail:
      case bookingService:
      case bookingPet:
      case bookingTimeSlot:
      case bookingConfirm:
      case payment:
      case myBookings:
      case bookingDetail:
      case reviewList:
      case reviewDetail:
      case createReview:
      case myReviews:
      case reminderList:
      case createReminder:
      case editReminder:
        return true;
      default:
        return false;
    }
  }

  static bool isStaffRoute(String routeName) {
    switch (routeName) {
      case staffDashboard:
      case staffBookingList:
      case staffBookingDetail:
      case createExaminationResult:
      case examinationResultDetail:
      case staffSchedule:
      case staffShiftRequest:
      case staffPetSearch:
      case staffPetDetail:
      case staffNotifications:
      case staffStatistics:
      case staffProfile:
      case editStaffProfile:
      case staffMore:
        return true;
      default:
        return false;
    }
  }

  static bool isAdminRoute(String routeName) {
    switch (routeName) {
      case adminDashboard:
      case adminBookingList:
      case adminBookingDetail:
      case adminReviewList:
      case adminReviewDetail:
      case adminShiftCalendar:
      case adminAssignShift:
      case shopSetting:
        return true;
      default:
        return false;
    }
  }

  static bool shouldShowBottomNav(String routeName) {
    return !isAuthRoute(routeName);
  }

  static bool isStaffPrimaryRoute(String routeName) {
    switch (routeName) {
      case staffDashboard:
      case staffSchedule:
      case staffPetSearch:
      case staffNotifications:
      case staffStatistics:
      case staffProfile:
      case staffMore:
        return true;
      default:
        return false;
    }
  }

  static String loginDestinationForRole(String? role) {
    switch (role) {
      case 'admin':
        return adminDashboard;
      case 'staff':
        return staffDashboard;
      default:
        return home;
    }
  }
}
