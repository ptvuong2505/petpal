import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
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
      child: RefreshIndicator(
        onRefresh: () => provider.loadBookingDetail(widget.bookingId),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Lịch hẹn #${booking.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StaffStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Thông tin lịch hẹn',
              children: [
                _InfoRow(label: 'Dịch vụ', value: booking.serviceName),
                _InfoRow(label: 'Ngày', value: booking.bookingDate ?? '-'),
                _InfoRow(label: 'Thời gian', value: _timeRange(booking)),
                _InfoRow(
                  label: 'Ghi chú khách hàng',
                  value: _valueOrDash(booking.bookingNote),
                ),
              ],
            ),
            _SectionCard(
              title: 'Khách hàng',
              children: [
                _InfoRow(label: 'Họ tên', value: booking.customerName),
                _InfoRow(
                  label: 'Điện thoại',
                  value: _valueOrDash(booking.customerPhone),
                ),
                _InfoRow(
                  label: 'Email',
                  value: _valueOrDash(booking.customerEmail),
                ),
              ],
            ),
            _SectionCard(
              title: 'Thú cưng',
              children: [
                _InfoRow(label: 'Tên', value: booking.petName),
                _InfoRow(
                  label: 'Loài',
                  value: _valueOrDash(booking.petSpecies),
                ),
                _InfoRow(label: 'Giống', value: _valueOrDash(booking.petBreed)),
                _InfoRow(
                  label: 'Giới tính',
                  value: _valueOrDash(booking.petGender),
                ),
                _InfoRow(
                  label: 'Ngày sinh',
                  value: _valueOrDash(booking.petBirthDate),
                ),
                _InfoRow(
                  label: 'Cân nặng',
                  value: booking.petWeight == null
                      ? '-'
                      : '${booking.petWeight} kg',
                ),
                _InfoRow(label: 'Lưu ý', value: _valueOrDash(booking.petNote)),
              ],
            ),
            if (provider.selectedResult case final result?)
              _ResultCard(result: result),
            const SizedBox(height: 4),
            Text(
              'Lịch sử khám gần đây',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (previousRecords.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có hồ sơ sức khỏe trước đó.'),
                ),
              )
            else
              ...previousRecords.map(_historyCard),
            const SizedBox(height: 12),
            if (!booking.hasResult &&
                (booking.status == 'pending' || booking.status == 'confirmed'))
              AppButton(
                label: 'Tạo kết quả khám/chăm sóc',
                icon: Icons.medical_information_outlined,
                onPressed: () => NavigationService.goTo(
                  context,
                  AppRoutes.createExaminationResult,
                  queryParameters: {'bookingId': booking.id.toString()},
                ),
              )
            else if (booking.hasResult)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.task_alt),
                label: const Text('Booking đã có kết quả'),
              )
            else
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.block),
                label: Text(
                  booking.status == 'cancelled'
                      ? 'Booking đã bị hủy'
                      : 'Booking đã hoàn thành',
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 22),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = Text(
          this.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: constraints.maxWidth < 320
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label, const SizedBox(height: 4), Text(value)],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 120, child: label),
                    Expanded(child: Text(value)),
                  ],
                ),
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ExaminationResult result;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Kết quả hiện tại',
      children: [
        _InfoRow(label: 'Tiêu đề', value: result.title),
        _InfoRow(label: 'Triệu chứng', value: result.symptom ?? '-'),
        _InfoRow(label: 'Chẩn đoán', value: result.diagnosis ?? '-'),
        _InfoRow(label: 'Xử lý', value: result.treatment ?? '-'),
        _InfoRow(label: 'Thuốc/dặn dò', value: result.medicine ?? '-'),
        _InfoRow(label: 'Ghi chú', value: result.note ?? '-'),
      ],
    );
  }
}
