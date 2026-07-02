import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../admin_service_management/providers/admin_service_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../pet_profile/providers/pet_profile_provider.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<PetProfileProvider>().loadPets(auth.currentUser!.id!);
    }
    context.read<AdminServiceProvider>().loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final petProvider = context.watch<PetProfileProvider>();
    final serviceProvider = context.watch<AdminServiceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _welcomeSection(auth),
              const SizedBox(height: 24),
              if (auth.isLoggedIn) ...[
                _sectionTitle('Thú cưng của tôi'),
                const SizedBox(height: 12),
                _petList(context, petProvider),
                const SizedBox(height: 24),
              ],
              _sectionTitle('Dịch vụ hệ thống'),
              const SizedBox(height: 12),
              _serviceGrid(serviceProvider),
              const SizedBox(height: 24),
              _bookingButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeSection(AuthProvider auth) {
    final name = auth.isLoggedIn ? auth.currentUser!.fullName : 'bạn';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào $name! 👋',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hôm nay các bé nhà mình thế nào?',
          style: TextStyle(fontSize: 16, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _petList(BuildContext context, PetProfileProvider provider) {
    if (provider.isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pets = provider.pets;

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1,
        itemBuilder: (context, index) {
          if (index == pets.length) {
            return _addPetCard(context);
          }
          final pet = pets[index];
          return _petCard(
            context: context,
            name: pet.name,
            breed: pet.breed ?? pet.species ?? 'Thú cưng',
            imagePath: pet.imagePath,
            onTap: () {
              context.read<PetProfileProvider>().selectPet(pet);
              NavigationService.goTo(context, AppRoutes.petDetail);
            },
          );
        },
      ),
    );
  }

  Widget _petCard({
    required BuildContext context,
    required String name,
    required String breed,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: imagePath != null && imagePath.isNotEmpty
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : const Icon(Icons.pets,
                        size: 36, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              breed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addPetCard(BuildContext context) {
    return InkWell(
      onTap: () => NavigationService.goTo(context, AppRoutes.addPet),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFC9C3), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.add, color: AppColors.primary),
            ),
            SizedBox(height: 10),
            Text(
              'Thêm thú cưng',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceGrid(AdminServiceProvider provider) {
    if (provider.isLoading && provider.services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final services = provider.services;

    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Đang cập nhật dịch vụ...'),
      );
    }

    return GridView.builder(
      itemCount: services.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        final name = service.name.toLowerCase();

        IconData icon = Icons.miscellaneous_services;
        Color bg = AppColors.secondaryContainer;

        if (name.contains('groom')) {
          icon = Icons.content_cut;
          bg = const Color(0xFFB5EAD7);
        } else if (name.contains('hotel')) {
          icon = Icons.bed;
          bg = const Color(0xFFE2F0CB);
        } else if (name.contains('health') || name.contains('khám')) {
          icon = Icons.favorite;
          bg = const Color(0xFFFFDAC1);
        } else if (name.contains('vaccin')) {
          icon = Icons.vaccines;
          bg = const Color(0xFFFFE5E5);
        } else if (name.contains('nail') || name.contains('ear')) {
          icon = Icons.clean_hands;
          bg = Colors.white;
        } else if (name.contains('dental') || name.contains('răng')) {
          icon = Icons.medical_services;
          bg = const Color(0xFFC7CEEA);
        }

        return InkWell(
          onTap: () {
            NavigationService.goTo(
              context,
              AppRoutes.adminServiceDetail,
              arguments: service,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<BookingProvider>().resetBookingFlow();
          NavigationService.goTo(context, AppRoutes.bookingService);
        },
        icon: const Icon(Icons.calendar_month),
        label: const Text('Đặt lịch ngay'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
