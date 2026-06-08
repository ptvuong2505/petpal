import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class BookingPetPage extends StatelessWidget {
  const BookingPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Booking Pet',
      message: 'Booking Pet Page',
      actions: [
        PageAction(
          label: 'Choose Time Slot',
          routeName: AppRoutes.bookingTimeSlot,
        ),
      ],
    );
  }
}
