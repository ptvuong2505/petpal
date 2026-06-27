import 'package:flutter/material.dart';
import 'package:petpal/features/auth/providers/auth_provider.dart';
import 'package:petpal/features/booking/providers/booking_provider.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/navigation_service.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({required this.currentRouteName, super.key});

  final String currentRouteName;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = context.watch<AuthProvider>();
    List<AppBottomNavItem> items = _buildBottomNavItems(auth);
    final selectedRouteName = _selectedRouteName(auth, currentRouteName);
    final currentIndex = items.indexWhere(
      (item) => item.routeName == selectedRouteName,
    );

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      onTap: (index) {
        final routeName = items[index].routeName;

        if (routeName == currentRouteName) {
          return;
        }

        if (routeName == AppRoutes.bookingService) {
          context.read<BookingProvider>().resetBookingFlow();
        }

        NavigationService.goTo(context, routeName);
      },
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  List<AppBottomNavItem> _buildBottomNavItems(AuthProvider auth) {
    if (!auth.isLoggedIn) {
      return const [
        AppBottomNavItem(
          label: 'Home',
          icon: Icons.home,
          routeName: AppRoutes.home,
        ),
        AppBottomNavItem(
          label: 'Login',
          icon: Icons.login,
          routeName: AppRoutes.login,
        ),
        AppBottomNavItem(
          label: 'Register',
          icon: Icons.person_add,
          routeName: AppRoutes.register,
        ),
      ];
    }

    switch (auth.currentRole) {
      case 'admin':
        return const [
          AppBottomNavItem(
            label: 'Home',
            icon: Icons.home,
            routeName: AppRoutes.home,
          ),
          AppBottomNavItem(
            label: 'Admin',
            icon: Icons.dashboard_customize,
            routeName: AppRoutes.adminDashboard,
          ),
          AppBottomNavItem(
            label: 'Slots',
            icon: Icons.schedule,
            routeName: AppRoutes.adminShiftCalendar,
          ),
          AppBottomNavItem(
            label: 'Shop',
            icon: Icons.store,
            routeName: AppRoutes.shopSetting,
          ),
          AppBottomNavItem(
            label: 'Profile',
            icon: Icons.person,
            routeName: AppRoutes.userProfile,
          ),
        ];

      case 'staff':
        return const [
          AppBottomNavItem(
            label: 'Tổng quan',
            icon: Icons.dashboard,
            routeName: AppRoutes.staffDashboard,
          ),
          AppBottomNavItem(
            label: 'Lịch',
            icon: Icons.calendar_month,
            routeName: AppRoutes.staffSchedule,
          ),
          AppBottomNavItem(
            label: 'Thú cưng',
            icon: Icons.pets,
            routeName: AppRoutes.staffPetSearch,
          ),
          AppBottomNavItem(
            label: 'Thông báo',
            icon: Icons.notifications,
            routeName: AppRoutes.staffNotifications,
          ),
          AppBottomNavItem(
            label: 'Thêm',
            icon: Icons.more_horiz,
            routeName: AppRoutes.staffMore,
          ),
        ];

      case 'user':
      default:
        return const [
          AppBottomNavItem(
            label: 'Home',
            icon: Icons.home,
            routeName: AppRoutes.home,
          ),
          AppBottomNavItem(
            label: 'Booking',
            icon: Icons.calendar_month,
            routeName: AppRoutes.bookingService,
          ),
          AppBottomNavItem(
            label: 'Pets',
            icon: Icons.pets,
            routeName: AppRoutes.petList,
          ),
          AppBottomNavItem(
            label: 'Reviews',
            icon: Icons.star,
            routeName: AppRoutes.myReviews,
          ),
          AppBottomNavItem(
            label: 'Profile',
            icon: Icons.person,
            routeName: AppRoutes.userProfile,
          ),
        ];
    }
  }

  String _selectedRouteName(AuthProvider auth, String routeName) {
    if (auth.currentRole == 'staff' &&
        (routeName == AppRoutes.staffStatistics ||
            routeName == AppRoutes.staffProfile ||
            routeName == AppRoutes.editStaffProfile)) {
      return AppRoutes.staffMore;
    }
    return routeName;
  }
}
