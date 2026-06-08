import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class BookingConfirmPage extends StatelessWidget {
  const BookingConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Booking Confirm',
      message: 'Booking Confirm Page',
      actions: [
        PageAction(label: 'My Bookings', routeName: AppRoutes.myBookings),
      ],
    );
  }
}
