import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../booking/providers/booking_provider.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _welcomeSection(),
            const SizedBox(height: 24),

            _sectionTitle('Thú cưng của tôi'),
            const SizedBox(height: 12),
            _petList(context),
            const SizedBox(height: 24),

            _sectionTitle('Dịch vụ'),
            const SizedBox(height: 12),
            _serviceGrid(),
            const SizedBox(height: 24),

            _bookingButton(context),
            const SizedBox(height: 24),

            _upcomingBookingSection(context),
          ],
        ),
      ),
    );
  }

  Widget _welcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào bạn! 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 6),
        Text(
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

  Widget _petList(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _petCard(name: 'Lulu', breed: 'Corgi', icon: Icons.pets),
          _petCard(name: 'Milo', breed: 'Golden Ret.', icon: Icons.pets),
          _addPetCard(context),
        ],
      ),
    );
  }

  Widget _petCard({
    required String name,
    required String breed,
    required IconData icon,
  }) {
    return Container(
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
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.secondaryContainer,
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            breed,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
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

  Widget _serviceGrid() {
    final services = [
      _HomeService(
        title: 'Grooming',
        icon: Icons.content_cut,
        color: AppColors.tertiaryContainer,
        routeName: AppRoutes.bookingService,
      ),
      _HomeService(
        title: 'Hotel',
        icon: Icons.hotel,
        color: AppColors.secondaryContainer,
        routeName: AppRoutes.bookingService,
      ),
      _HomeService(
        title: 'Khám sức khỏe',
        icon: Icons.monitor_heart,
        color: AppColors.primaryContainer,
        routeName: AppRoutes.healthRecordList,
      ),
      _HomeService(
        title: 'Tiêm phòng',
        icon: Icons.vaccines,
        color: Color(0xFFFFDAD6),
        routeName: AppRoutes.healthRecordList,
      ),
    ];

    return GridView.builder(
      itemCount: services.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final service = services[index];

        return InkWell(
          onTap: () {
            if (service.routeName == AppRoutes.bookingService) {
              context.read<BookingProvider>().resetBookingFlow();
            }
            NavigationService.goTo(context, service.routeName);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: service.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(service.icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 2,
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

  Widget _upcomingBookingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Lịch hẹn sắp tới')),
            TextButton(
              onPressed: () =>
                  NavigationService.goTo(context, AppRoutes.myBookings),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.pets, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grooming & Tắm sấy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cho bé Lulu',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Sắp tới',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              const Row(
                children: [
                  Icon(Icons.event, size: 20, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text(
                    'Thứ Bảy, 12 Tháng 10, 2023',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text(
                    '09:00 SA',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeService {
  const _HomeService({
    required this.title,
    required this.icon,
    required this.color,
    required this.routeName,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String routeName;
}
