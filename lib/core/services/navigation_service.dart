import 'package:flutter/widgets.dart';

abstract interface class AppNavigationController {
  void goTo(
    String routeName, {
    Object? arguments,
    Map<String, String> queryParameters,
  });

  void goBack();
}

class NavigationService {
  static void goTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Map<String, String> queryParameters = const {},
  }) {
    final delegate = Router.of(context).routerDelegate;
    if (delegate is AppNavigationController) {
      (delegate as AppNavigationController).goTo(
        routeName,
        arguments: arguments,
        queryParameters: queryParameters,
      );
    }
  }

  static void goBack(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    if (delegate is AppNavigationController) {
      (delegate as AppNavigationController).goBack();
    }
  }
}
