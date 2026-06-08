import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class BookingServicePage extends StatelessWidget {
  const BookingServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Booking Service',
      message: 'Booking Service Page',
      actions: [
        PageAction(label: 'Choose Pet', routeName: AppRoutes.bookingPet),
        PageAction(label: 'My Bookings', routeName: AppRoutes.myBookings),
      ],
    );
  }
}
