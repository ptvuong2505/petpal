import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Login',
      message: 'Login Page',
      actions: [
        PageAction(label: 'Register', routeName: AppRoutes.register),
        PageAction(
          label: 'Forgot Password',
          routeName: AppRoutes.forgotPassword,
        ),
      ],
    );
  }
}
