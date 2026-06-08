import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class BookingTimeSlotPage extends StatelessWidget {
  const BookingTimeSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Booking Time Slot',
      message: 'Booking Time Slot Page',
      actions: [
        PageAction(label: 'Confirm', routeName: AppRoutes.bookingConfirm),
      ],
    );
  }
}
