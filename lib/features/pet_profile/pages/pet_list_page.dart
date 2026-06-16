import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/pet.dart';
import '../providers/pet_profile_provider.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<PetProfileProvider>().loadPets(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProfileProvider>();
    final pets = petProvider.pets;

    // Trả về nội dung trực tiếp, Scaffold và AppBar đã được AppLayout bọc ở ngoài
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Để màu nền đồng nhất với Layout chính
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () => NavigationService.goTo(context, AppRoutes.addPet),
          backgroundColor: AppColors.primaryContainer,
          child: const Icon(Icons.add, color: AppColors.primary),
        ),
      ),
      body: petProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pets.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: pets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _PetCard(pet: pet);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có thú cưng nào',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet});

  final Pet pet;

  String _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 'Không rõ tuổi';
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int years = now.year - birth.year;
      int months = now.month - birth.month;
      if (months < 0) {
        years--;
        months += 12;
      }
      if (years > 0) return '$years tuổi';
      return '$months tháng';
    } catch (e) {
      return 'Không rõ tuổi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<PetProfileProvider>().selectPet(pet);
        NavigationService.goTo(context, AppRoutes.petDetail);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: pet.imagePath != null && pet.imagePath!.isNotEmpty
                    ? Image.file(File(pet.imagePath!), fit: BoxFit.cover)
                    : const Icon(
                        Icons.pets,
                        size: 40,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed ?? pet.species ?? 'Chưa xác định',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniInfo(
                        Icons.cake_outlined,
                        _calculateAge(pet.birthDate),
                      ),
                      const SizedBox(width: 20),
                      _buildMiniInfo(
                        Icons.monitor_weight_outlined,
                        '${pet.weight ?? 0}kg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        ),
      ],
    );
  }
}
