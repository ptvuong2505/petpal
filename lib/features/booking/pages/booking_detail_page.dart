import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Booking Detail',
      message: 'Booking Detail Page',
      actions: [
        PageAction(label: 'My Bookings', routeName: AppRoutes.myBookings),
      ],
    );
  }
}
