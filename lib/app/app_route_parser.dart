import 'package:flutter/widgets.dart';

import 'app_route_path.dart';

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }

    return AppRoutePath.byLocation('/${uri.pathSegments.join('/')}');
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(uri: Uri.parse(configuration.location));
  }
}
