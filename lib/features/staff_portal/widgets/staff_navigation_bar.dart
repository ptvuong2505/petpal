import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';

const _staffDestinationRoutes = <String>[
  AppRoutes.staffDashboard,
  AppRoutes.staffSchedule,
  AppRoutes.staffPetSearch,
  AppRoutes.staffNotifications,
  AppRoutes.staffMore,
];

int staffNavigationIndexForRoute(String routeName) {
  switch (routeName) {
    case AppRoutes.staffDashboard:
    case AppRoutes.staffBookingList:
    case AppRoutes.staffBookingDetail:
    case AppRoutes.createExaminationResult:
    case AppRoutes.examinationResultDetail:
      return 0;
    case AppRoutes.staffSchedule:
    case AppRoutes.staffShiftRequest:
      return 1;
    case AppRoutes.staffPetSearch:
    case AppRoutes.staffPetDetail:
      return 2;
    case AppRoutes.staffNotifications:
      return 3;
    case AppRoutes.staffMore:
    case AppRoutes.staffStatistics:
    case AppRoutes.staffProfile:
    case AppRoutes.editStaffProfile:
      return 4;
    default:
      return 0;
  }
}

class StaffNavigationBar extends StatelessWidget {
  const StaffNavigationBar({required this.currentRouteName, super.key});

  final String currentRouteName;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: staffNavigationIndexForRoute(currentRouteName),
      onDestinationSelected: (index) {
        final destination = _staffDestinationRoutes[index];
        if (destination == currentRouteName) return;
        NavigationService.goTo(context, destination);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Lịch',
        ),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'Thú cưng',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more),
          label: 'Thêm',
        ),
      ],
    );
  }
}
