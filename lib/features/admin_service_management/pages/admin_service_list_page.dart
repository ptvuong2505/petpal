import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../booking/models/service.dart';
import '../providers/admin_service_provider.dart';

class AdminServiceListPage extends StatefulWidget {
  const AdminServiceListPage({super.key});

  @override
  State<AdminServiceListPage> createState() => _AdminServiceListPageState();
}

class _AdminServiceListPageState extends State<AdminServiceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminServiceProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            NavigationService.goTo(context, AppRoutes.adminAddService),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminServiceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.services.isEmpty) {
            return const Center(child: Text('Chưa có dịch vụ nào.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = provider.services[index];
              return _ServiceCard(service: service);
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    final statusColor = service.status == 'active' ? Colors.green : Colors.grey;

    return InkWell(
      onTap: () => NavigationService.goTo(
        context,
        AppRoutes.adminServiceDetail,
        arguments: service,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.miscellaneous_services,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.price.toInt()}đ • ${service.durationMinutes} phút',
                    style: const TextStyle(color: AppColors.subText),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit,
                      size: 20, color: AppColors.primary),
                  onPressed: () => NavigationService.goTo(
                    context,
                    AppRoutes.adminEditService,
                    arguments: service,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
