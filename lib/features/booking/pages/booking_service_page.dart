import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../models/service.dart' as model;
import '../providers/booking_provider.dart';

class BookingServicePage extends StatefulWidget {
  const BookingServicePage({super.key});

  @override
  State<BookingServicePage> createState() => _BookingServicePageState();
}

class _BookingServicePageState extends State<BookingServicePage> {
  List<_ServiceItem> _services = [];
  bool _isLoading = true;

  void _toggle(int serviceId) {
    context.read<BookingProvider>().toggleService(serviceId);
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
    });

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'services',
      where: 'status = ?',
      whereArgs: ['active'],
    );
    final list = rows.map((r) => model.Service.fromMap(r)).toList();

    // Map DB services to UI items with icons/colors
    final items = list.map((s) {
      final name = s.name.toLowerCase();
      IconData icon = Icons.miscellaneous_services;
      Color bg = AppColors.secondaryContainer;

      if (name.contains('groom') || name.contains('grooming')) {
        icon = Icons.content_cut;
        bg = AppColors.primaryContainer;
      } else if (name.contains('hotel') || name.contains('pet hotel')) {
        icon = Icons.bed;
        bg = AppColors.secondaryContainer;
      } else if (name.contains('health') || name.contains('khám')) {
        icon = Icons.favorite;
        bg = AppColors.tertiaryContainer;
      } else if (name.contains('vaccin') || name.contains('vaccine')) {
        icon = Icons.vaccines;
        bg = const Color(0xFFFFDAD6);
      } else if (name.contains('nail') || name.contains('ear')) {
        icon = Icons.clean_hands;
        bg = AppColors.surface;
      } else if (name.contains('dental') || name.contains('răng')) {
        icon = Icons.medical_services;
        bg = AppColors.primaryContainer;
      }

      return _ServiceItem(
        id: s.id ?? 0,
        title: s.name,
        description: s.description ?? '',
        priceLabel: s.price > 0 ? 'Từ ${s.price.toInt()}đ' : 'Liên hệ',
        icon: icon,
        bgColor: bg,
      );
    }).toList();

    setState(() {
      _services = items;
      _isLoading = false;
    });
  }

  void _continue() {
    final selectedIds = context.read<BookingProvider>().selectedServiceIds;
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một dịch vụ')),
      );
      return;
    }

    // For now just navigate to choose pet step
    NavigationService.goTo(context, AppRoutes.bookingPet);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedServiceIds = context
        .watch<BookingProvider>()
        .selectedServiceIds;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Vui lòng chọn các dịch vụ bạn muốn đặt cho thú cưng của mình.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final s = _services[index];
              final selected = selectedServiceIds.contains(s.id);

              return GestureDetector(
                onTap: () => _toggle(s.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: s.bgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s.icon, color: AppColors.primary),
                          ),
                          AnimatedOpacity(
                            opacity: selected ? 1 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: Transform.scale(
                              scale: selected ? 1 : 0.6,
                              child: Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          s.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.priceLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Tiếp tục'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.icon,
    required this.bgColor,
  });

  final int id;
  final String title;
  final String description;
  final String priceLabel;
  final IconData icon;
  final Color bgColor;
}
