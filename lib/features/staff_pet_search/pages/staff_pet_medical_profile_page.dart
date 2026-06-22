import 'package:flutter/material.dart';

import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';

class StaffPetMedicalProfilePage extends StatefulWidget {
  const StaffPetMedicalProfilePage({required this.petId, super.key});

  final int petId;

  @override
  State<StaffPetMedicalProfilePage> createState() => _State();
}

class _State extends State<StaffPetMedicalProfilePage> {
  final _dao = StaffPortalDao();
  Map<String, Object?>? _data;
  bool _loading = true;
  String? _errorMessage;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _dao.petDetail(widget.petId);
      if (mounted) setState(() => _data = data);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Không thể tải hồ sơ thú cưng.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
    if (_loading) return const StaffLoadingState();
    if (_errorMessage != null) {
      return StaffErrorState(message: _errorMessage!, onRetry: _load);
    }
    final data = _data;
    if (data == null) {
      return StaffEmptyState(
        icon: Icons.pets_outlined,
        message: 'Không tìm thấy hồ sơ thú cưng.',
        onRetry: _load,
      );
    }
    final rawRecords = data['records'];
    final records = rawRecords is List
        ? rawRecords.whereType<Map<String, Object?>>().toList()
        : <Map<String, Object?>>[];
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['name'] ?? 'Chưa đặt tên'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '${data['species'] ?? 'Chưa cập nhật'} • ${data['breed'] ?? 'Chưa cập nhật'}',
                  ),
                  const Divider(),
                  Text('Chủ nuôi: ${data['owner_name'] ?? 'Chưa cập nhật'}'),
                  Text(
                    '${data['owner_phone'] ?? '-'} • ${data['owner_email'] ?? '-'}',
                  ),
                  if ('${data['note'] ?? ''}'.trim().isNotEmpty)
                    Text('Lưu ý: ${data['note']}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch sử bệnh án',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Chưa có bệnh án.')),
            ),
          ...records.map(
            (record) => Card(
              child: ListTile(
                leading: const Icon(Icons.medical_information_outlined),
                title: Text('${record['title'] ?? 'Kết quả khám'}'),
                subtitle: Text(
                  '${record['record_date'] ?? 'Chưa cập nhật'}\n'
                  'Chẩn đoán: ${record['diagnosis'] ?? 'Chưa có thông tin'}\n'
                  'Điều trị: ${record['treatment'] ?? 'Chưa có thông tin'}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
