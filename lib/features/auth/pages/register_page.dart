import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/app_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Register',
      message: 'Register Page',
      actions: [PageAction(label: 'Login', routeName: AppRoutes.login)],
    );
  }
}
