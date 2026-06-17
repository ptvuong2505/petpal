import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Forgot Password',
      message: 'Forgot Password Page',
      actions: [PageAction(label: 'Login', routeName: AppRoutes.login)],
    );
  }
}
