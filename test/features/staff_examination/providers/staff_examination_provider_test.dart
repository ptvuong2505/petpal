import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/features/staff_examination/data/staff_examination_dao.dart';
import 'package:petpal/features/staff_examination/models/examination_result.dart';
import 'package:petpal/features/staff_examination/models/staff_booking.dart';
import 'package:petpal/features/staff_examination/providers/staff_examination_provider.dart';
import 'package:petpal/features/staff_examination/repositories/staff_examination_repository.dart';

void main() {
  const booking = StaffBooking(
    id: 4,
    userId: 2,
    petId: 8,
    serviceName: 'Health Check',
    customerName: 'Nguyen An',
    petName: 'Milo',
  );
  const previousRecord = ExaminationResult(
    id: 1,
    petId: 8,
    title: 'Previous visit',
  );

  test('loads staff bookings and clears an earlier error', () async {
    final repository = FakeStaffExaminationRepository()
      ..bookings = const [booking];
    final provider = StaffExaminationProvider(repository: repository);

    await provider.loadBookings(date: '2026-06-12', status: 'confirmed');

    expect(provider.bookings, const [booking]);
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
    expect(repository.requestedDate, '2026-06-12');
    expect(repository.requestedStatus, 'confirmed');
  });

  test('loads booking detail together with pet history and result', () async {
    final repository = FakeStaffExaminationRepository()
      ..bookingDetail = booking
      ..history = const [previousRecord]
      ..bookingResult = previousRecord;
    final provider = StaffExaminationProvider(repository: repository);

    await provider.loadBookingDetail(4);

    expect(provider.selectedBooking, booking);
    expect(provider.petHealthRecords, const [previousRecord]);
    expect(provider.selectedResult, previousRecord);
    expect(provider.errorMessage, isNull);
  });

  test(
    'exposes repository errors instead of throwing from the provider',
    () async {
      final repository = FakeStaffExaminationRepository()
        ..error = Exception('Booking already has a health record');
      final provider = StaffExaminationProvider(repository: repository);

      final saved = await provider.createExaminationResult(previousRecord);

      expect(saved, isNull);
      expect(provider.isSubmitting, isFalse);
      expect(provider.errorMessage, contains('Booking already has'));
    },
  );
}

class FakeStaffExaminationRepository extends StaffExaminationRepository {
  FakeStaffExaminationRepository() : super(dao: StaffExaminationDao());

  List<StaffBooking> bookings = const [];
  StaffBooking? bookingDetail;
  List<ExaminationResult> history = const [];
  ExaminationResult? bookingResult;
  Object? error;
  String? requestedDate;
  String? requestedStatus;

  @override
  Future<List<StaffBooking>> getBookings({String? date, String? status}) async {
    if (error case final error?) throw error;
    requestedDate = date;
    requestedStatus = status;
    return bookings;
  }

  @override
  Future<StaffBooking?> getBookingDetail(int bookingId) async {
    if (error case final error?) throw error;
    return bookingDetail;
  }

  @override
  Future<List<ExaminationResult>> getPetHealthRecords(int petId) async {
    if (error case final error?) throw error;
    return history;
  }

  @override
  Future<ExaminationResult?> getResultByBooking(int bookingId) async {
    if (error case final error?) throw error;
    return bookingResult;
  }

  @override
  Future<int> createResult(ExaminationResult result) async {
    if (error case final error?) throw error;
    return 1;
  }
}
