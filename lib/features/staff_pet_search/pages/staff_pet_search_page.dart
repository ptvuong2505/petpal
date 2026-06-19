import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../staff_portal/data/staff_portal_dao.dart';

class StaffPetSearchPage extends StatefulWidget {
  const StaffPetSearchPage({super.key});
  @override
  State<StaffPetSearchPage> createState() => _StaffPetSearchPageState();
}

class _StaffPetSearchPageState extends State<StaffPetSearchPage> {
  final _dao = StaffPortalDao();
  final _controller = TextEditingController();
  Timer? _timer;
  List<Map<String, Object?>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    setState(() => _loading = true);
    final items = await _dao.searchPets(value);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Tên thú cưng, chủ nuôi, email hoặc số điện thoại',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _timer?.cancel();
            _timer = Timer(
              const Duration(milliseconds: 350),
              () => _search(value),
            );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? const Center(child: Text('Không tìm thấy thú cưng.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.pets)),
                        title: Text('${item['name']}'),
                        subtitle: Text(
                          '${item['species'] ?? ''} ${item['breed'] ?? ''}\n'
                          'Chủ: ${item['owner_name']} • ${item['owner_phone'] ?? item['owner_email']}',
                        ),
                        isThreeLine: true,
                        trailing: Text('${item['record_count']} hồ sơ'),
                        onTap: () => NavigationService.goTo(
                          context,
                          AppRoutes.staffPetDetail,
                          queryParameters: {'petId': '${item['id']}'},
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
