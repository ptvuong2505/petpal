import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/core/constants/app_routes.dart';
import 'package:petpal/features/auth/data/auth_dao.dart';
import 'package:petpal/features/auth/models/user.dart';
import 'package:petpal/features/auth/providers/auth_provider.dart';
import 'package:petpal/features/auth/repositories/auth_repository.dart';
import 'package:petpal/features/staff_examination/data/staff_examination_dao.dart';
import 'package:petpal/features/staff_examination/models/examination_result.dart';
import 'package:petpal/features/staff_examination/models/staff_booking.dart';
import 'package:petpal/features/staff_examination/pages/create_examination_result_page.dart';
import 'package:petpal/features/staff_examination/pages/staff_booking_detail_page.dart';
import 'package:petpal/features/staff_examination/pages/staff_booking_list_page.dart';
import 'package:petpal/features/staff_examination/pages/staff_dashboard_page.dart';
import 'package:petpal/features/staff_examination/providers/staff_examination_provider.dart';
import 'package:petpal/features/staff_examination/repositories/staff_examination_repository.dart';
import 'package:petpal/shared/layouts/staff_layout.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('staff dashboard fits 360x640 with long booking text', (
    tester,
  ) async {
    await _pumpStaffPage(
      tester,
      title: 'Staff Dashboard',
      routeName: AppRoutes.staffDashboard,
      page: const StaffDashboardPage(),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('staff booking list fits 360x640 with filters', (tester) async {
    await _pumpStaffPage(
      tester,
      title: 'Staff Booking List',
      routeName: AppRoutes.staffBookingList,
      page: const StaffBookingListPage(),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('staff booking detail fits 360x640 with long sections', (
    tester,
  ) async {
    await _pumpStaffPage(
      tester,
      title: 'Staff Booking Detail',
      routeName: AppRoutes.staffBookingDetail,
      page: const StaffBookingDetailPage(bookingId: 1),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('create result form fits 360x640 when keyboard is open', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);

    await _pumpStaffPage(
      tester,
      title: 'Create Examination Result',
      routeName: AppRoutes.createExaminationResult,
      page: const CreateExaminationResultPage(bookingId: 1),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('create result form fits 320x568 when keyboard is open', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);

    await _pumpStaffPage(
      tester,
      title: 'Create Examination Result',
      routeName: AppRoutes.createExaminationResult,
      page: const CreateExaminationResultPage(bookingId: 1),
      size: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpStaffPage(
  WidgetTester tester, {
  required String title,
  required String routeName,
  required Widget page,
  Size size = const Size(360, 640),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final auth = AuthProvider(repository: AuthRepository(dao: AuthDao()))
    ..currentUser = const User(
      id: 3,
      fullName: 'Staff',
      email: 'staff@gmail.com',
      role: 'staff',
    );
  final staffProvider = StaffExaminationProvider(
    repository: _FakeStaffRepository(),
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: staffProvider),
      ],
      child: MaterialApp(
        home: StaffLayout(
          title: title,
          currentRouteName: routeName,
          child: page,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeStaffRepository extends StaffExaminationRepository {
  _FakeStaffRepository() : super(dao: StaffExaminationDao());

  static const booking = StaffBooking(
    id: 1,
    userId: 2,
    petId: 3,
    serviceName: 'Khám sức khỏe tổng quát và tư vấn dinh dưỡng dài hạn',
    bookingDate: '2026-06-12',
    status: 'confirmed',
    bookingNote:
        'Khách hàng ghi chú rất dài để kiểm tra khả năng xuống dòng trên màn hình nhỏ.',
    customerName: 'Nguyễn Văn Khách Hàng Có Tên Rất Dài',
    customerEmail: 'customer.with.a.very.long.email.address@example.com',
    customerPhone: '090123456789012345',
    petName: 'Milo Với Tên Hiển Thị Rất Dài',
    petSpecies: 'Dog',
    petBreed: 'Poodle lai giống có tên dài',
    petGender: 'Male',
    petBirthDate: '2022-05-10',
    petWeight: 5.6,
    petNote: 'Lưu ý chăm sóc dài để kiểm tra responsive detail.',
    startTime: '09:00',
    endTime: '10:00',
  );

  @override
  Future<List<StaffBooking>> getBookings({String? date, String? status}) async {
    return const [booking, booking, booking];
  }

  @override
  Future<StaffBooking?> getBookingDetail(int bookingId) async => booking;

  @override
  Future<List<ExaminationResult>> getPetHealthRecords(int petId) async {
    return const [
      ExaminationResult(
        id: 9,
        petId: 3,
        title: 'Hồ sơ sức khỏe trước đây với tiêu đề rất dài',
        diagnosis: 'Chẩn đoán dài để kiểm tra khả năng responsive.',
        staffName: 'Nhân viên có tên dài',
        recordDate: '2026-05-10',
      ),
    ];
  }

  @override
  Future<ExaminationResult?> getResultByBooking(int bookingId) async => null;
}
