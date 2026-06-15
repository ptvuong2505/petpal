import 'package:flutter/material.dart';

import '../../staff_portal/data/staff_portal_dao.dart';

class StaffPetMedicalProfilePage extends StatefulWidget {
  const StaffPetMedicalProfilePage({required this.petId, super.key});
  final int petId;
  @override
  State<StaffPetMedicalProfilePage> createState() => _State();
}

class _State extends State<StaffPetMedicalProfilePage> {
  final _dao = StaffPortalDao();
  Map<String, Object?>? _data;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _dao.petDetail(widget.petId);
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const Center(child: CircularProgressIndicator());
    final records = (data['records'] as List).cast<Map<String, Object?>>();
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['name']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${data['species'] ?? ''} • ${data['breed'] ?? ''}'),
                const Divider(),
                Text('Chủ nuôi: ${data['owner_name']}'),
                Text(
                  '${data['owner_phone'] ?? ''} • ${data['owner_email'] ?? ''}',
                ),
                if ('${data['note'] ?? ''}'.isNotEmpty)
                  Text('Lưu ý: ${data['note']}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Lịch sử bệnh án', style: Theme.of(context).textTheme.titleLarge),
        if (records.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Chưa có bệnh án.')),
          ),
        ...records.map(
          (record) => Card(
            child: ListTile(
              leading: const Icon(Icons.medical_information_outlined),
              title: Text('${record['title']}'),
              subtitle: Text(
                '${record['record_date'] ?? ''}\nChẩn đoán: ${record['diagnosis'] ?? 'Không có thông tin'}\n'
                'Điều trị: ${record['treatment'] ?? 'Không có thông tin'}\n'
                'Thuốc: ${record['medicine'] ?? 'Không có thông tin'}',
              ),
              isThreeLine: true,
            ),
          ),
        ),
      ],
    );
  }
}
