import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_content.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../models/examination_result.dart';
import '../models/staff_booking.dart';
import '../providers/staff_examination_provider.dart';
import '../widgets/staff_status_badge.dart';

class StaffBookingDetailPage extends StatefulWidget {
  const StaffBookingDetailPage({required this.bookingId, super.key});

  final int bookingId;

  @override
  State<StaffBookingDetailPage> createState() => _StaffBookingDetailPageState();
}

class _StaffBookingDetailPageState extends State<StaffBookingDetailPage> {
  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _loadBooking,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();

    if (provider.isLoading ||
        provider.selectedBooking?.id != widget.bookingId) {
      if (provider.errorMessage != null && !provider.isLoading) {
        return StaffErrorState(
          message: provider.errorMessage!,
          onRetry: _loadBooking,
        );
      }
      return const StaffLoadingState();
    }

    final booking = provider.selectedBooking;
    if (booking == null) {
      return StaffEmptyState(
        icon: Icons.event_busy_outlined,
        message: 'Không tìm thấy lịch hẹn.',
        onRetry: _loadBooking,
      );
    }
    final previousRecords = provider.petHealthRecords
        .where((record) => record.id != provider.selectedResult?.id)
        .take(3)
        .toList();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadBookingDetail(widget.bookingId),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Lịch hẹn #${booking.id}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              StaffStatusBadge(status: booking.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _timeRange(booking),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(booking.bookingDate ?? 'Không có ngày hẹn'),
                          const SizedBox(height: 12),
                          Text(
                            booking.petName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(booking.serviceName),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StaffInfoSection(
                    title: 'Thông tin lịch hẹn',
                    icon: Icons.event_note_outlined,
                    children: [
                      StaffInfoRow(
                        label: 'Dịch vụ',
                        value: booking.serviceName,
                      ),
                      StaffInfoRow(
                        label: 'Ngày',
                        value: booking.bookingDate ?? '-',
                      ),
                      StaffInfoRow(
                        label: 'Thời gian',
                        value: _timeRange(booking),
                      ),
                      StaffInfoRow(
                        label: 'Ghi chú khách hàng',
                        value: _valueOrDash(booking.bookingNote),
                      ),
                    ],
                  ),
                  StaffInfoSection(
                    title: 'Thông tin chủ nuôi',
                    icon: Icons.person_outline,
                    children: [
                      StaffInfoRow(
                        label: 'Họ tên',
                        value: booking.customerName,
                      ),
                      StaffInfoRow(
                        label: 'Điện thoại',
                        value: _valueOrDash(booking.customerPhone),
                      ),
                      StaffInfoRow(
                        label: 'Email',
                        value: _valueOrDash(booking.customerEmail),
                      ),
                    ],
                  ),
                  StaffInfoSection(
                    title: 'Thông tin thú cưng',
                    icon: Icons.pets_outlined,
                    children: [
                      StaffInfoRow(label: 'Tên', value: booking.petName),
                      StaffInfoRow(
                        label: 'Loài',
                        value: _valueOrDash(booking.petSpecies),
                      ),
                      StaffInfoRow(
                        label: 'Giống',
                        value: _valueOrDash(booking.petBreed),
                      ),
                      StaffInfoRow(
                        label: 'Giới tính',
                        value: _valueOrDash(booking.petGender),
                      ),
                      StaffInfoRow(
                        label: 'Ngày sinh',
                        value: _valueOrDash(booking.petBirthDate),
                      ),
                      StaffInfoRow(
                        label: 'Cân nặng',
                        value: booking.petWeight == null
                            ? '-'
                            : '${booking.petWeight} kg',
                      ),
                      StaffInfoRow(
                        label: 'Lưu ý',
                        value: _valueOrDash(booking.petNote),
                      ),
                    ],
                  ),
                  if (provider.selectedResult case final result?)
                    _ResultCard(result: result),
                  const SizedBox(height: 8),
                  const StaffSectionHeader(title: 'Lịch sử khám gần đây'),
                  const SizedBox(height: 8),
                  if (previousRecords.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Chưa có hồ sơ sức khỏe trước đó.'),
                    )
                  else
                    ...previousRecords.map(_historyCard),
                ],
              ),
            ),
          ),
          StaffStickyActionBar(
            child: _buildPrimaryAction(context, booking, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction(
    BuildContext context,
    StaffBooking booking,
    StaffExaminationProvider provider,
  ) {
    if (!booking.hasResult &&
        (booking.status == 'pending' || booking.status == 'confirmed')) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => NavigationService.goTo(
            context,
            AppRoutes.createExaminationResult,
            queryParameters: {'bookingId': booking.id.toString()},
          ),
          icon: const Icon(Icons.medical_information_outlined),
          label: const Text('Tạo kết quả khám'),
        ),
      );
    }
    if (booking.resultId case final resultId?) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: () => NavigationService.goTo(
            context,
            AppRoutes.examinationResultDetail,
            queryParameters: {'resultId': resultId.toString()},
          ),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Xem kết quả'),
        ),
      );
    }
    if (provider.selectedResult != null || booking.hasResult) {
      return const Text('Booking đã có kết quả khám.');
    }
    return Text(
      booking.status == 'cancelled'
          ? 'Booking đã bị hủy.'
          : 'Booking đã hoàn thành nhưng chưa có kết quả để tạo mới.',
    );
  }

  Future<void> _loadBooking() {
    return context.read<StaffExaminationProvider>().loadBookingDetail(
      widget.bookingId,
    );
  }

  Widget _historyCard(ExaminationResult record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.medical_services_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (record.recordDate?.isNotEmpty == true)
                        record.recordDate!,
                      if (record.diagnosis?.isNotEmpty == true)
                        record.diagnosis!,
                      if (record.staffName?.isNotEmpty == true)
                        record.staffName!,
                    ].join(' • '),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeRange(StaffBooking booking) {
    if (booking.startTime == null) return '-';
    if (booking.endTime == null) return booking.startTime!;
    return '${booking.startTime} - ${booking.endTime}';
  }

  String _valueOrDash(String? value) {
    return value == null || value.trim().isEmpty ? '-' : value;
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ExaminationResult result;

  @override
  Widget build(BuildContext context) {
    return StaffInfoSection(
      title: 'Kết quả hiện tại',
      icon: Icons.description_outlined,
      children: [
        StaffInfoRow(label: 'Tiêu đề', value: result.title),
        StaffInfoRow(label: 'Triệu chứng', value: result.symptom ?? '-'),
        StaffInfoRow(label: 'Chẩn đoán', value: result.diagnosis ?? '-'),
        StaffInfoRow(label: 'Xử lý', value: result.treatment ?? '-'),
        StaffInfoRow(label: 'Thuốc/dặn dò', value: result.medicine ?? '-'),
        StaffInfoRow(label: 'Ghi chú', value: result.note ?? '-'),
      ],
    );
  }
}
