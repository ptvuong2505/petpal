import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/navigation_service.dart';
import '../../pet_profile/models/pet.dart' as Model;
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class BookingPetPage extends StatefulWidget {
  const BookingPetPage({super.key});

  @override
  State<BookingPetPage> createState() => _BookingPetPageState();
}

class _BookingPetPageState extends State<BookingPetPage> {
  List<Model.Pet> _pets = [];
  bool _isLoading = true;
  int? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;

    final db = await AppDatabase.instance.database;
    List<Map<String, Object?>> rows;
    if (userId != null) {
      rows = await db.query('pets', where: 'user_id = ?', whereArgs: [userId]);
    } else {
      rows = await db.query('pets');
    }

    final list = rows.map((r) => Model.Pet.fromMap(r)).toList();

    setState(() {
      _pets = list;
      _isLoading = false;
    });
  }

  void _selectPet(int id) {
    setState(() {
      _selectedPetId = id;
    });
    context.read<BookingProvider>().selectPet(id);
  }

  void _continue() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vui lòng chọn một thú cưng')));
      return;
    }

    // Navigate to time slot selection
    NavigationService.goTo(context, AppRoutes.bookingTimeSlot);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isCheckingLogin || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn cần đăng nhập để tiếp tục đặt lịch.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => NavigationService.goTo(context, AppRoutes.login),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Chọn thú cưng để đặt dịch vụ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Bạn chưa có thú cưng nào.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => NavigationService.goTo(context, AppRoutes.addPet),
                        child: const Text('Thêm thú cưng'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _pets.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    if (index == _pets.length) {
                      // Add new pet card
                      return InkWell(
                        onTap: () => NavigationService.goTo(context, AppRoutes.addPet),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3F3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBFC9C3), width: 1.5),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(
                                backgroundColor: AppColors.secondaryContainer,
                                child: Icon(Icons.add, color: AppColors.primary),
                              ),
                              SizedBox(width: 12),
                              Text('Thêm thú cưng', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }

                    final pet = _pets[index];
                    final selected = _selectedPetId == pet.id;

                    return GestureDetector(
                      onTap: () => _selectPet(pet.id!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primaryContainer : Colors.transparent,
                            width: 2,
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
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.secondaryContainer,
                              child: Icon(Icons.pets, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(pet.breed ?? pet.species ?? '', style: const TextStyle(color: Color(0xFF707974))),
                                  if ((pet.note ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(pet.note!, style: const TextStyle(color: Color(0xFF707974))),
                                  ]
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle, color: AppColors.primary)
                            else
                              const SizedBox(width: 24),
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
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
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


