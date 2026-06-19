import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../pet_profile/providers/pet_profile_provider.dart';
import '../providers/health_record_provider.dart';

class HealthRecordListPage extends StatefulWidget {
  const HealthRecordListPage({super.key});

  @override
  State<HealthRecordListPage> createState() => _HealthRecordListPageState();
}

class _HealthRecordListPageState extends State<HealthRecordListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petId = context.read<PetProfileProvider>().selectedPet?.id;
      if (petId != null) {
        context.read<HealthRecordProvider>().loadRecordsByPetId(petId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProfileProvider>().selectedPet;
    final recordProvider = context.watch<HealthRecordProvider>();
    final records = recordProvider.records;

    if (pet == null) {
      return const Center(child: Text('Không tìm thấy thông tin thú cưng'));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        NavigationService.goTo(context, AppRoutes.petList);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondaryContainer,
                    backgroundImage:
                    pet.imagePath != null && pet.imagePath!.isNotEmpty
                        ? FileImage(File(pet.imagePath!))
                        : null,
                    child: pet.imagePath == null || pet.imagePath!.isEmpty
                        ? const Icon(Icons.pets, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${pet.breed ?? pet.species} • ${_calculateAge(pet.birthDate)}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline List
          Expanded(
            child: recordProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : records.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return _HealthTimelineItem(
                  record: records[index],
                  isLast: index == records.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Chưa có hồ sơ sức khỏe nào',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 'Không rõ tuổi';
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
      return 'Không rõ tuổi';
    }
  }
}

class _HealthTimelineItem extends StatelessWidget {
  final dynamic record;
  final bool isLast;

  const _HealthTimelineItem({required this.record, required this.isLast});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.medical_services_outlined;
    Color iconColor = Colors.teal;
    Color bgColor = Colors.teal.shade50;

    if (record.title.toString().toLowerCase().contains('vaccin')) {
      iconData = Icons.vaccines_outlined;
      iconColor = Colors.blue;
      bgColor = Colors.blue.shade50;
    } else if (record.title.toString().toLowerCase().contains('surg')) {
      iconData = Icons.content_cut;
      iconColor = Colors.orange;
      bgColor = Colors.orange.shade50;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(record.recordDate),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  NavigationService.goTo(
                    context,
                    AppRoutes.healthRecordDetail,
                    arguments: record,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            record.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (record.diagnosis != null && record.diagnosis.isNotEmpty)
                      _buildDetailRow(
                        Icons.search,
                        'Chẩn đoán',
                        record.diagnosis,
                      ),
                    if (record.symptom != null && record.symptom.isNotEmpty)
                      _buildDetailRow(
                        Icons.coronavirus_outlined,
                        'Triệu chứng',
                        record.symptom,
                      ),
                    if (record.note != null && record.note.isNotEmpty)
                      _buildDetailRow(
                        Icons.note_alt_outlined,
                        'Ghi chú',
                        record.note,
                      ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.orange.shade50,
                          child: const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Bác sĩ phụ trách',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ], // Đóng children của Column
                ), // Đóng Column
              ), // Đóng InkWell
            ), // Đóng Container
          ), // Đóng Expanded của Content Card
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--/--';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
    } catch (_) {
      return dateStr;
    }
  }
}