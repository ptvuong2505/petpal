import 'package:flutter/widgets.dart';

abstract interface class AppNavigationController {
  void goTo(String routeName, {Object? arguments});
}

class NavigationService {
  static void goTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    final delegate = Router.of(context).routerDelegate;
    if (delegate is AppNavigationController) {
      (delegate as AppNavigationController).goTo(
        routeName,
        arguments: arguments,
      );
    }
  }
}
