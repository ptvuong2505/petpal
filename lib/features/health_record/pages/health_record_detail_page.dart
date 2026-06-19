import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../pet_profile/providers/pet_profile_provider.dart';
import '../models/health_record.dart';

class HealthRecordDetailPage extends StatelessWidget {
  const HealthRecordDetailPage({super.key, this.record});

  final HealthRecord? record;

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProfileProvider>().selectedPet;

    // Nếu không có record được truyền vào (ví dụ qua deep link), có thể xử lý ở đây
    if (record == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin hồ sơ sức khỏe')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E2E2).withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.secondaryContainer,
                      backgroundImage: pet?.imagePath != null && pet!.imagePath!.isNotEmpty
                          ? FileImage(File(pet.imagePath!))
                          : null,
                      child: pet?.imagePath == null || pet!.imagePath!.isEmpty
                          ? const Icon(Icons.pets, color: AppColors.primary, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet?.name ?? 'Thú cưng',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${pet?.species ?? 'N/A'} • ${pet?.breed ?? 'N/A'} • ${_calculateAge(pet?.birthDate)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Health Record Details Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E2E2).withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      iconColor: Colors.blue,
                      title: 'Ngày khám',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatFullDate(record!.recordDate),
                            style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.local_hospital, size: 16, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 4),
                              Text(
                                'Phòng khám Thú y PetPal Care',
                                style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    _buildDetailSection(
                      icon: Icons.sick_outlined,
                      iconColor: Colors.red,
                      title: 'Triệu chứng',
                      content: Text(
                        record!.symptom ?? 'Không có thông tin ghi nhận.',
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                      ),
                    ),
                    const Divider(height: 32),

                    _buildDetailSection(
                      icon: Icons.biotech_outlined,
                      iconColor: AppColors.primary,
                      title: 'Chẩn đoán',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              record!.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record!.diagnosis ?? 'Chưa có kết luận chi tiết.',
                            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    _buildDetailSection(
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.blue,
                      title: 'Kết quả khám chi tiết',
                      content: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.5,
                        children: [
                          _buildStatItem('Nhiệt độ', '38.5°C'),
                          _buildStatItem('Cân nặng', '${pet?.weight ?? '--'} kg'),
                          _buildStatItem('Nhịp tim', '110 bpm'),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    _buildDetailSection(
                      icon: Icons.medication_outlined,
                      iconColor: AppColors.primary,
                      title: 'Thuốc / Hướng dẫn chăm sóc',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (record!.medicine != null && record!.medicine!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryContainer),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Toa thuốc:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record!.medicine!,
                                    style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            record!.treatment ?? 'Nghỉ ngơi và theo dõi tại nhà.',
                            style: const TextStyle(fontSize: 14, color: AppColors.onSurface, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    // Follow-up
                    _buildDetailSection(
                      icon: Icons.event_repeat_outlined,
                      iconColor: Colors.orange,
                      title: 'Ngày tái khám',
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record!.nextVisitDate != null && record!.nextVisitDate!.isNotEmpty
                                ? _formatSimpleDate(record!.nextVisitDate)
                                : 'Không có lịch hẹn',
                            style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
                          ),
                          if (record!.nextVisitDate != null && record!.nextVisitDate!.isNotEmpty)
                            ElevatedButton(
                              onPressed: () => NavigationService.goTo(context, AppRoutes.bookingService),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryContainer,
                                foregroundColor: const Color(0xFF3D4B2B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text('Đặt lịch'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    // Notes
                    _buildDetailSection(
                      icon: Icons.notes_outlined,
                      iconColor: AppColors.outline,
                      title: 'Ghi chú thêm',
                      content: Text(
                        record!.note ?? 'Không có ghi chú thêm.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
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

  Widget _buildDetailSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 'N/A';
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int years = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        years--;
      }
      return '$years tuổi';
    } catch (_) {
      return 'N/A';
    }
  }

  String _formatFullDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--/--/----';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year} - 09:30 AM';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatSimpleDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--/--/----';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
