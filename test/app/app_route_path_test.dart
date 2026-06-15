import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/app/app_route_parser.dart';
import 'package:petpal/app/app_route_path.dart';
import 'package:petpal/core/constants/app_routes.dart';

void main() {
  test('parses bookingId from a staff detail location', () {
    final path = AppRoutePath.byLocation('/staff/bookings/detail?bookingId=12');

    expect(path.routeName, AppRoutes.staffBookingDetail);
    expect(path.bookingId, 12);
    expect(path.location, '/staff/bookings/detail?bookingId=12');
  });

  test('builds a named staff route with bookingId', () {
    final path = AppRoutePath.byName(
      AppRoutes.createExaminationResult,
      queryParameters: const {'bookingId': '7'},
    );

    expect(path.bookingId, 7);
    expect(path.location, '/staff/examination-results/create?bookingId=7');
  });

  test('route parser preserves bookingId query parameter', () async {
    final path = await AppRouteParser().parseRouteInformation(
      RouteInformation(uri: Uri.parse('/staff/bookings/detail?bookingId=15')),
    );

    expect(path.bookingId, 15);
    expect(path.location, '/staff/bookings/detail?bookingId=15');
  });

  test('route parser preserves resultId query parameter', () async {
    final path = await AppRouteParser().parseRouteInformation(
      RouteInformation(
        uri: Uri.parse('/staff/examination-results/detail?resultId=9'),
      ),
    );

    expect(path.routeName, AppRoutes.examinationResultDetail);
    expect(path.resultId, 9);
    expect(path.location, '/staff/examination-results/detail?resultId=9');
  });

  test('route parser preserves petId query parameter', () async {
    final path = await AppRouteParser().parseRouteInformation(
      RouteInformation(uri: Uri.parse('/staff/pets/detail?petId=4')),
    );

    expect(path.routeName, AppRoutes.staffPetDetail);
    expect(path.petId, 4);
    expect(path.location, '/staff/pets/detail?petId=4');
  });

  test('parses resultId from an examination result detail location', () {
    final path = AppRoutePath.byLocation(
      '/staff/examination-results/detail?resultId=9',
    );

    expect(path.routeName, AppRoutes.examinationResultDetail);
    expect(path.resultId, 9);
  });

  test('parses petId from a staff pet detail location', () {
    final path = AppRoutePath.byLocation('/staff/pets/detail?petId=4');

    expect(path.routeName, AppRoutes.staffPetDetail);
    expect(path.petId, 4);
  });
}
