import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class EditStaffProfilePage extends StatefulWidget {
  const EditStaffProfilePage({super.key});
  @override
  State<EditStaffProfilePage> createState() => _EditStaffProfilePageState();
}

class _EditStaffProfilePageState extends State<EditStaffProfilePage> {
  final _dao = StaffPortalDao();
  final _specialty = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();
  final _certificates = TextEditingController();
  bool _loading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final data = await _dao.staffProfile(id);
    _specialty.text = '${data?['specialty'] ?? ''}';
    _experience.text = '${data?['experience_years'] ?? 0}';
    _bio.text = '${data?['bio'] ?? ''}';
    try {
      _certificates.text = (jsonDecode('${data?['certificate_names']}') as List)
          .join('\n');
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    await _dao.saveProfile(
      staffId: id,
      specialty: _specialty.text.trim(),
      experienceYears: int.tryParse(_experience.text) ?? 0,
      bio: _bio.text.trim(),
      certificates: _certificates.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    if (mounted) NavigationService.goTo(context, AppRoutes.staffProfile);
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      children: [
        TextField(
          controller: _specialty,
          decoration: const InputDecoration(
            labelText: 'Chuyên khoa',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _experience,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số năm kinh nghiệm',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bio,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Giới thiệu chuyên môn',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _certificates,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Chứng chỉ (mỗi dòng một chứng chỉ)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Lưu hồ sơ'),
        ),
      ],
    );
  }
}
