import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_content.dart';
import '../../staff_portal/widgets/staff_state_view.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  final _dao = StaffPortalDao();
  Map<String, Object?>? _profile;
  bool _loading = true;
  String? _errorMessage;

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _dao.staffProfile(id);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Không thể tải hồ sơ Staff.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _certificates(Object? value) {
    try {
      final decoded = jsonDecode('$value');
      if (decoded is! List) return [];
      return decoded
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
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
    final profile = _profile;
    if (profile == null) {
      return StaffEmptyState(
        icon: Icons.person_search_outlined,
        message: 'Chưa có thông tin hồ sơ Staff.',
        onRetry: _load,
      );
    }
    final certificates = _certificates(profile['certificate_names']);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          child: Icon(Icons.medical_services, size: 38),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _value(profile['full_name']),
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StaffInfoSection(
                  title: 'Thông tin liên hệ',
                  icon: Icons.contact_phone_outlined,
                  children: [
                    StaffInfoRow(
                      label: 'Email',
                      value: _value(profile['email']),
                    ),
                    StaffInfoRow(
                      label: 'Điện thoại',
                      value: _value(profile['phone']),
                    ),
                  ],
                ),
                StaffInfoSection(
                  title: 'Chuyên môn',
                  icon: Icons.medical_services_outlined,
                  children: [
                    StaffInfoRow(
                      label: 'Chuyên khoa',
                      value: _value(profile['specialty']),
                    ),
                    StaffInfoRow(
                      label: 'Kinh nghiệm',
                      value: '${_experience(profile['experience_years'])} năm',
                    ),
                    StaffInfoRow(
                      label: 'Giới thiệu',
                      value: _value(profile['bio']),
                    ),
                  ],
                ),
                StaffInfoSection(
                  title: 'Chứng chỉ',
                  icon: Icons.workspace_premium_outlined,
                  children: [
                    if (certificates.isEmpty)
                      const Text('Chưa cập nhật chứng chỉ.')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: certificates
                            .map(
                              (certificate) => Chip(
                                avatar: const Icon(
                                  Icons.workspace_premium_outlined,
                                  size: 18,
                                ),
                                label: Text(certificate),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          StaffStickyActionBar(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    NavigationService.goTo(context, AppRoutes.editStaffProfile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Chỉnh sửa chuyên môn'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _value(Object? value) {
    final text = '$value'.trim();
    return text.isEmpty || text == 'null' ? 'Chưa cập nhật' : text;
  }

  int _experience(Object? value) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }
}
