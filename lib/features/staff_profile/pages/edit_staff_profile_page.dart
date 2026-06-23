import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_content.dart';
import '../../staff_portal/widgets/staff_state_view.dart';
import '../validators/staff_profile_validation.dart';

class EditStaffProfilePage extends StatefulWidget {
  const EditStaffProfilePage({super.key});

  @override
  State<EditStaffProfilePage> createState() => _EditStaffProfilePageState();
}

class _EditStaffProfilePageState extends State<EditStaffProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _dao = StaffPortalDao();
  final _specialty = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();
  final _certificates = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _dao.staffProfile(id);
      _specialty.text = '${data?['specialty'] ?? ''}';
      _experience.text = '${data?['experience_years'] ?? 0}';
      _bio.text = '${data?['bio'] ?? ''}';
      try {
        final certificates = jsonDecode(
          '${data?['certificate_names'] ?? '[]'}',
        );
        _certificates.text = certificates is List
            ? certificates.join('\n')
            : '';
      } catch (_) {
        _certificates.clear();
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Không thể tải hồ sơ Staff.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;

    setState(() => _saving = true);
    try {
      await _dao.saveProfile(
        staffId: id,
        specialty: _specialty.text.trim(),
        experienceYears: int.parse(_experience.text.trim()),
        bio: _bio.text.trim(),
        certificates: cleanedCertificates(_certificates.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ Staff.')));
      NavigationService.goTo(context, AppRoutes.staffProfile);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu hồ sơ. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _specialty.dispose();
    _experience.dispose();
    _bio.dispose();
    _certificates.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      onAllowed: _load,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) return const StaffLoadingState(skeleton: true);
    if (_errorMessage != null) {
      return StaffErrorState(message: _errorMessage!, onRetry: _load);
    }
    return SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Hồ sơ chuyên môn',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _specialty,
                    enabled: !_saving,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'Chuyên khoa *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _experience,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateExperience,
                    decoration: const InputDecoration(
                      labelText: 'Số năm kinh nghiệm (0–80)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bio,
                    enabled: !_saving,
                    maxLines: 5,
                    maxLength: 500,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateBio,
                    decoration: const InputDecoration(
                      labelText: 'Giới thiệu chuyên môn *',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _certificates,
                    enabled: !_saving,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Chứng chỉ',
                      helperText: 'Mỗi dòng một chứng chỉ',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            StaffStickyActionBar(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu hồ sơ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
