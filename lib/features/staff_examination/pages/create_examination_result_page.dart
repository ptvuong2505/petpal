import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../models/examination_result.dart';
import '../providers/staff_examination_provider.dart';
import '../validators/examination_result_validation.dart';

class CreateExaminationResultPage extends StatefulWidget {
  const CreateExaminationResultPage({required this.bookingId, super.key});

  final int bookingId;

  @override
  State<CreateExaminationResultPage> createState() =>
      _CreateExaminationResultPageState();
}

class _CreateExaminationResultPageState
    extends State<CreateExaminationResultPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _symptomController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _medicineController = TextEditingController();
  final _noteController = TextEditingController();
  final _nextVisitController = TextEditingController();
  bool _isConfirming = false;

  @override
  void dispose() {
    _titleController.dispose();
    _symptomController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _medicineController.dispose();
    _noteController.dispose();
    _nextVisitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _loadBooking,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<StaffExaminationProvider>();
    final booking = provider.selectedBooking;

    if (provider.isLoading || booking?.id != widget.bookingId) {
      if (provider.errorMessage != null && !provider.isLoading) {
        return _LoadError(
          message: provider.errorMessage!,
          onRetry: _loadBooking,
        );
      }
      return const AppLoading();
    }

    if (booking == null) {
      return _LoadError(
        message: 'Không tìm thấy lịch hẹn.',
        onRetry: _loadBooking,
      );
    }

    if (booking.hasResult ||
        provider.selectedResult != null ||
        booking.status == 'completed' ||
        booking.status == 'cancelled') {
      return _ResponsiveState(
        icon: Icons.task_alt,
        iconColor: Colors.green,
        message: booking.hasResult || provider.selectedResult != null
            ? 'Booking này đã có kết quả.'
            : booking.status == 'cancelled'
            ? 'Booking này đã bị hủy.'
            : 'Booking này đã hoàn thành.',
        action: AppButton(label: 'Quay lại chi tiết', onPressed: _goToDetail),
      );
    }

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kết quả cho ${booking.petName}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${booking.serviceName} • Booking #${booking.id}'),
                    const SizedBox(height: 20),
                    _field(
                      controller: _titleController,
                      label: 'Tiêu đề hồ sơ *',
                      validator: _required('Vui lòng nhập tiêu đề.'),
                    ),
                    _field(
                      controller: _symptomController,
                      label: 'Triệu chứng *',
                      maxLines: 3,
                      validator: (value) => validateRequiredText(
                        value,
                        'Vui lòng nhập triệu chứng.',
                      ),
                    ),
                    _field(
                      controller: _diagnosisController,
                      label: 'Chẩn đoán *',
                      maxLines: 3,
                      validator: (value) => validateRequiredText(
                        value,
                        'Vui lòng nhập chẩn đoán.',
                      ),
                    ),
                    _field(
                      controller: _treatmentController,
                      label: 'Hướng điều trị *',
                      maxLines: 3,
                      validator: (value) => validateRequiredText(
                        value,
                        'Vui lòng nhập hướng điều trị.',
                      ),
                    ),
                    _field(
                      controller: _medicineController,
                      label: 'Thuốc / dặn dò',
                      maxLines: 3,
                    ),
                    _field(
                      controller: _noteController,
                      label: 'Ghi chú',
                      maxLines: 3,
                    ),
                    _field(
                      controller: _nextVisitController,
                      label: 'Ngày tái khám (YYYY-MM-DD)',
                      keyboardType: TextInputType.datetime,
                      validator: validateNextVisitDate,
                    ),
                    if (provider.errorMessage != null) ...[
                      Text(
                        provider.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    AppButton(
                      label: provider.isSubmitting
                          ? 'Đang lưu...'
                          : _isConfirming
                          ? 'Đang xác nhận...'
                          : 'Lưu kết quả',
                      icon: Icons.save_outlined,
                      onPressed: provider.isSubmitting || _isConfirming
                          ? null
                          : _submit,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  Future<void> _loadBooking() async {
    final provider = context.read<StaffExaminationProvider>();
    await provider.loadBookingDetail(widget.bookingId);
    if (!mounted) return;

    final booking = provider.selectedBooking;
    if (booking != null && _titleController.text.isEmpty) {
      _titleController.text =
          'Kết quả ${booking.serviceName} cho ${booking.petName}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<StaffExaminationProvider>();
    final booking = provider.selectedBooking;
    final staffId = context.read<AuthProvider>().currentUser?.id;
    if (_isConfirming || provider.isSubmitting) return;
    if (booking == null || booking.id != widget.bookingId) return;
    if (staffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xác định được tài khoản Staff.')),
      );
      return;
    }

    setState(() => _isConfirming = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hoàn tất lịch khám?'),
        content: const Text(
          'Lưu kết quả này sẽ đánh dấu lịch hẹn là hoàn thành.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xác nhận lưu'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _isConfirming = false);
    if (confirmed != true || provider.isSubmitting) return;

    final now = DateTime.now();
    final result = ExaminationResult(
      bookingId: booking.id,
      petId: booking.petId,
      staffId: staffId,
      title: _titleController.text.trim(),
      symptom: _symptomController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      treatment: _treatmentController.text.trim(),
      medicine: _medicineController.text.trim(),
      note: _noteController.text.trim(),
      recordDate: _dateValue(now),
      nextVisitDate: _nullableText(_nextVisitController.text),
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    final resultId = await provider.createExaminationResult(result);
    if (!mounted) return;

    if (resultId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Không thể lưu kết quả.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu kết quả và hoàn thành booking.')),
    );
    NavigationService.goTo(
      context,
      AppRoutes.examinationResultDetail,
      queryParameters: {'resultId': resultId.toString()},
    );
  }

  void _goToDetail() {
    NavigationService.goTo(
      context,
      AppRoutes.staffBookingDetail,
      queryParameters: {'bookingId': widget.bookingId.toString()},
    );
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveState(
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      message: message,
      action: AppButton(label: 'Thử lại', onPressed: onRetry),
    );
  }
}

class _ResponsiveState extends StatelessWidget {
  const _ResponsiveState({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > 32
                    ? constraints.maxHeight - 32
                    : 0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 48, color: iconColor),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    action,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
