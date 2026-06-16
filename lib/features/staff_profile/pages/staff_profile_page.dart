import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});
  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  final _dao = StaffPortalDao();
  Map<String, Object?>? _profile;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null) _load();
  }

  Future<void> _load() async {
    final id = context.read<AuthProvider>().currentUser?.id;
    if (id == null) return;
    final value = await _dao.staffProfile(id);
    if (mounted) {
      setState(() => _profile = value);
    }
  }

  List<String> _certificates(Object? value) {
    try {
      return (jsonDecode('$value') as List).map((e) => '$e').toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final certificates = _certificates(profile['certificate_names']);
    return ListView(
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
                  '${profile['full_name']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${profile['email']} • ${profile['phone'] ?? ''}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => NavigationService.goTo(
                    context,
                    AppRoutes.editStaffProfile,
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa chuyên môn'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chuyên môn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('${profile['specialty'] ?? 'Chưa cập nhật'}'),
                const SizedBox(height: 8),
                Text('Kinh nghiệm: ${profile['experience_years'] ?? 0} năm'),
                const SizedBox(height: 8),
                Text('${profile['bio'] ?? 'Chưa có giới thiệu.'}'),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chứng chỉ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (certificates.isEmpty)
                  const Text('Chưa cập nhật chứng chỉ.'),
                ...certificates.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.workspace_premium),
                    title: Text(item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
