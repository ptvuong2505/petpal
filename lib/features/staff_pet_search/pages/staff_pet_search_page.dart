import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../staff_portal/data/staff_portal_dao.dart';
import '../../staff_portal/widgets/staff_access_guard.dart';
import '../../staff_portal/widgets/staff_state_view.dart';

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
  bool _loading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  int _requestId = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _hasSearched = true;
    });
    try {
      final items = await _dao.searchPets(query);
      if (!mounted || requestId != _requestId) return;
      setState(() => _items = items);
    } catch (_) {
      if (mounted && requestId == _requestId) {
        setState(() => _errorMessage = 'Không thể tìm kiếm thú cưng.');
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  void _onChanged(String value) {
    _timer?.cancel();
    if (value.trim().isEmpty) {
      _requestId++;
      setState(() {
        _items = [];
        _loading = false;
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }
    setState(() {});
    _timer = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  void _clearSearch() {
    _timer?.cancel();
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return StaffAccessGuard(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _timer?.cancel();
                  _search(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Xóa từ khóa',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear),
                        ),
                  labelText: 'Tên thú cưng, chủ nuôi, email hoặc số điện thoại',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) return const StaffLoadingState();
    if (_errorMessage != null) {
      return StaffErrorState(
        message: _errorMessage!,
        onRetry: () => _search(_controller.text),
      );
    }
    if (!_hasSearched) {
      return const StaffEmptyState(
        icon: Icons.search,
        message: 'Nhập từ khóa để tìm thú cưng.',
      );
    }
    if (_items.isEmpty) {
      return StaffEmptyState(
        icon: Icons.pets_outlined,
        message: 'Không tìm thấy thú cưng.',
        onRetry: () => _search(_controller.text),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final species = '${item['species'] ?? ''}'.trim();
        final breed = '${item['breed'] ?? ''}'.trim();
        final ownerContact = item['owner_phone'] ?? item['owner_email'] ?? '-';
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.pets)),
            title: Text('${item['name'] ?? 'Chưa đặt tên'}'),
            subtitle: Text(
              '${[species, breed].where((value) => value.isNotEmpty).join(' ')}\n'
              'Chủ: ${item['owner_name'] ?? 'Chưa cập nhật'} • $ownerContact',
            ),
            isThreeLine: true,
            trailing: Text('${item['record_count'] ?? 0} hồ sơ'),
            onTap: () => NavigationService.goTo(
              context,
              AppRoutes.staffPetDetail,
              queryParameters: {'petId': '${item['id']}'},
            ),
          ),
        );
      },
    );
  }
}
