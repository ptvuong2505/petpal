import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'My Bookings',
      message: 'My Bookings Page',
      actions: [
        PageAction(label: 'Booking Detail', routeName: AppRoutes.bookingDetail),
        PageAction(label: 'Create Review', routeName: AppRoutes.createReview),
      ],
    );
  }
}
