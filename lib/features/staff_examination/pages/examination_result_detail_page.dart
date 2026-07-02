import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../providers/staff_examination_provider.dart';

class ExaminationResultDetailPage extends StatefulWidget {
  const ExaminationResultDetailPage({required this.resultId, super.key});

  final int resultId;

  @override
  State<ExaminationResultDetailPage> createState() =>
      _ExaminationResultDetailPageState();
}

class _ExaminationResultDetailPageState
    extends State<ExaminationResultDetailPage> {
  Future<void> _load() {
    return context.read<StaffExaminationProvider>().loadResultDetail(
          widget.resultId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _load,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();
    if (provider.isLoadingResultDetail) return const StaffLoadingState();
    if (provider.errorMessage != null) {
      return StaffErrorState(message: provider.errorMessage!, onRetry: _load);
    }
    final result = provider.resultDetail;
    if (result == null) {
      return StaffEmptyState(
        icon: Icons.description_outlined,
        message: 'Không tìm thấy kết quả khám.',
        onRetry: _load,
      );
    }

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Text(
            result.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _section('Thông tin chung', [
            _row('Thú cưng', _text(result.petName)),
            _row(
              'Giống loài',
              [result.petSpecies, result.petBreed]
                  .where((value) => value != null && value.trim().isNotEmpty)
                  .join(' - '),
            ),
            _row('Chủ nuôi', _text(result.ownerName)),
            _row('Dịch vụ', _text(result.serviceName)),
            _row('Bác sĩ/Nhân viên', _text(result.staffName)),
            _row('Ngày khám', _text(result.recordDate ?? result.bookingDate)),
            _row(
              'Khung giờ',
              result.startTime == null
                  ? 'Không có thông tin'
                  : '${result.startTime} - ${result.endTime ?? ''}',
            ),
          ]),
          _medical('Triệu chứng', result.symptom),
          _medical('Chẩn đoán', result.diagnosis),
          _medical('Hướng điều trị', result.treatment),
          _medical('Đơn thuốc', result.medicine),
          _medical('Dặn dò sau khám', result.note),
          _section('Tái khám', [
            _row('Ngày tái khám', _text(result.nextVisitDate)),
          ]),
        ],
      ),
    );
  }

  Widget _medical(String title, String? value) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_text(value)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Không có thông tin' : value)),
        ],
      ),
    );
  }

  String _text(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'Không có thông tin' : text;
  }
}
