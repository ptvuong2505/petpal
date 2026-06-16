import 'package:flutter/widgets.dart';

abstract interface class AppNavigationController {
  void goTo(String routeName);
}

class NavigationService {
  static void goTo(BuildContext context, String routeName) {
    final delegate = Router.of(context).routerDelegate;
    if (delegate is AppNavigationController) {
      (delegate as AppNavigationController).goTo(routeName);
    }
  }
}
