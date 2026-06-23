import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import '../../pet_profile/models/pet.dart';
import '../../pet_profile/providers/pet_profile_provider.dart';
import '../models/health_record.dart';

class HealthRecordDetailPage extends StatefulWidget {
  const HealthRecordDetailPage({super.key, this.record});

  final HealthRecord? record;

  @override
  State<HealthRecordDetailPage> createState() => _HealthRecordDetailPageState();
}

class _HealthRecordDetailPageState extends State<HealthRecordDetailPage> {
  Pet? _pet;
  bool _isLoadingPet = true;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    if (widget.record == null) {
      setState(() => _isLoadingPet = false);
      return;
    }

    final petProvider = context.read<PetProfileProvider>();
    // Thử tìm trong list đã load sẵn
    final existingPet = petProvider.pets.cast<Pet?>().firstWhere(
      (p) => p?.id == widget.record!.petId,
      orElse: () => null,
    );

    if (existingPet != null) {
      setState(() {
        _pet = existingPet;
        _isLoadingPet = false;
      });
    } else {
      // Nếu không thấy, load từ DB
      try {
        final db = await AppDatabase.instance.database;
        final rows = await db.query(
          'pets',
          where: 'id = ?',
          whereArgs: [widget.record!.petId],
        );
        if (rows.isNotEmpty && mounted) {
          setState(() {
            _pet = Pet.fromMap(rows.first);
            _isLoadingPet = false;
          });
        } else {
          setState(() => _isLoadingPet = false);
        }
      } catch (e) {
        debugPrint('Error loading pet: $e');
        setState(() => _isLoadingPet = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.record == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin hồ sơ sức khỏe'),
      );
    }

    final record = widget.record!;

    if (_isLoadingPet) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Info Card
          InkWell(
            onTap: () {
              if (_pet != null) {
                context.read<PetProfileProvider>().selectPet(_pet!);
                NavigationService.goTo(context, AppRoutes.petDetail);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                ),
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryContainer,
                        width: 2,
                      ),
                      image:
                          _pet?.imagePath != null && _pet!.imagePath!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(_pet!.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _pet?.imagePath == null || _pet!.imagePath!.isEmpty
                        ? const Icon(
                            Icons.pets,
                            color: AppColors.primary,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pet?.name ?? 'Thú cưng',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${_pet?.species ?? 'Chưa rõ'} • ${_pet?.breed ?? 'Chưa rõ'} • ${_calculateAge(_pet?.birthDate)}',
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
          ),
          const SizedBox(height: 16),

          // Health Record Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant),
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
                // Date & Clinic
                _buildSection(
                  icon: Icons.calendar_today,
                  iconColor: AppColors.secondary,
                  title: 'Ngày khám',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFullDate(record.recordDate),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.local_hospital,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Phòng khám Thú y PetCare Plus',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Symptoms
                _buildSection(
                  icon: Icons.sick,
                  iconColor: AppColors.error,
                  title: 'Triệu chứng',
                  content: Text(
                    record.symptom ?? 'Không có thông tin ghi nhận.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Diagnosis
                _buildSection(
                  icon: Icons.biotech,
                  iconColor: AppColors.primary,
                  title: 'Chẩn đoán',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          record.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.diagnosis ?? 'Chưa có kết luận chi tiết.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Detailed Results
                _buildSection(
                  icon: Icons.science,
                  iconColor: AppColors.secondary,
                  title: 'Kết quả khám chi tiết',
                  content: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.0,
                    children: [
                      _buildStatItem('Nhiệt độ', '38.5°C (Bình thường)'),
                      _buildStatItem('Cân nặng', '${_pet?.weight ?? '--'} kg'),
                      _buildStatItem('Nhịp tim', '110 bpm'),
                    ],
                  ),
                ),
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Medication
                _buildSection(
                  icon: Icons.medication,
                  iconColor: AppColors.primary,
                  title: 'Thuốc / Hướng dẫn chăm sóc',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.medicine != null &&
                          record.medicine!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thuốc tiêu hóa Probiotic',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.medicine!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        record.treatment ?? 'Theo dõi tại nhà.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Follow-up
                _buildSection(
                  icon: Icons.event_repeat,
                  iconColor: AppColors.tertiary,
                  title: 'Ngày tái khám',
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.nextVisitDate != null &&
                                record.nextVisitDate!.isNotEmpty
                            ? _formatSimpleDate(record.nextVisitDate)
                            : 'Không có lịch hẹn',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (record.nextVisitDate != null &&
                          record.nextVisitDate!.isNotEmpty)
                        ElevatedButton(
                          onPressed: () => NavigationService.goTo(
                            context,
                            AppRoutes.bookingService,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.onSecondaryContainer,
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
                const Divider(height: 32, color: AppColors.surfaceVariant),

                // Notes
                _buildSection(
                  icon: Icons.notes,
                  iconColor: AppColors.outline,
                  title: 'Ghi chú thêm',
                  content: Text(
                    record.note ?? 'Không có ghi chú thêm.',
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
    );
  }

  Widget _buildSection({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              height: 1.2,
            ),
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
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
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
