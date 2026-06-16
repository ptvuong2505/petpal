import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../providers/pet_profile_provider.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProfileProvider>().selectedPet;

    if (pet == null) {
      return const Center(child: Text('Không tìm thấy thông tin thú cưng'));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        NavigationService.goTo(context, AppRoutes.petList);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Ảnh thú cưng lớn
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child:
                            pet.imagePath != null && pet.imagePath!.isNotEmpty
                            ? Image.file(
                                File(pet.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.secondaryContainer,
                                child: const Icon(
                                  Icons.pets,
                                  size: 100,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                    // Overlay Tên và Giống
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              pet.breed ?? pet.species ?? 'Chưa xác định',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Thông số chi tiết
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildInfoCard(
                          'Loài',
                          pet.species ?? 'Khác',
                          Icons.category_outlined,
                          Colors.blue.shade50,
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                          'Giới tính',
                          pet.gender ?? 'Chưa rõ',
                          Icons.transgender,
                          Colors.orange.shade50,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'Ngày sinh',
                      pet.birthDate ?? 'Chưa cập nhật',
                      Icons.cake_outlined,
                      Colors.pink.shade50,
                      Colors.pink,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoCard(
                          'Cân nặng',
                          '${pet.weight ?? 0} kg',
                          Icons.monitor_weight_outlined,
                          Colors.teal.shade50,
                          Colors.teal,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                          'Mã định danh',
                          'PET-${pet.id ?? '000'}',
                          Icons.qr_code,
                          Colors.grey.shade100,
                          Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Nút hành động
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            NavigationService.goTo(context, AppRoutes.editPet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Chỉnh sửa thông tin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => NavigationService.goTo(
                          context,
                          AppRoutes.healthRecordList,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryContainer,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xem toàn bộ hồ sơ sức khỏe',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    bool fullWidth = false,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: content)
        : Expanded(child: content);
  }
}
