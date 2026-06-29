import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../booking/models/service.dart';
import '../providers/admin_service_provider.dart';

class AdminServiceDetailPage extends StatelessWidget {
  const AdminServiceDetailPage({required this.service, super.key});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () => NavigationService.goTo(
                  context,
                  AppRoutes.adminEditService,
                  arguments: service,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.miscellaneous_services, size: 50, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          _InfoTile(label: 'Tên dịch vụ', value: service.name, isTitle: true),
          _InfoTile(label: 'Giá (VNĐ)', value: '${service.price.toInt()}đ'),
          _InfoTile(label: 'Thời lượng', value: '${service.durationMinutes} phút'),
          _InfoTile(label: 'Trạng thái', value: service.status.toUpperCase()),
          const SizedBox(height: 16),
          const Text(
            'Mô tả dịch vụ',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.subText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.description ?? 'Không có mô tả.',
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${service.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminServiceProvider>().deleteService(service.id!);
              if (success && context.mounted) {
                NavigationService.goBack(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa dịch vụ thành công')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.isTitle = false});
  final String label;
  final String value;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTitle ? 20 : 16,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
