import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../features/admin_dashboard/data/admin_dashboard_dao.dart';
import '../features/admin_dashboard/providers/admin_dashboard_provider.dart';
import '../features/admin_dashboard/repositories/admin_dashboard_repository.dart';
import '../features/auth/data/auth_dao.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/booking/data/booking_dao.dart';
import '../features/booking/providers/booking_provider.dart';
import '../features/booking/repositories/booking_repository.dart';
import '../features/health_record/data/health_record_dao.dart';
import '../features/health_record/providers/health_record_provider.dart';
import '../features/health_record/repositories/health_record_repository.dart';
import '../features/pet_profile/data/pet_profile_dao.dart';
import '../features/pet_profile/providers/pet_profile_provider.dart';
import '../features/pet_profile/repositories/pet_profile_repository.dart';
import '../features/payment/data/payment_dao.dart';
import '../features/payment/providers/payment_provider.dart';
import '../features/payment/repositories/payment_repository.dart';
import '../features/payment/services/payos_client.dart';
import '../features/reminder/data/reminder_dao.dart';
import '../features/reminder/providers/reminder_provider.dart';
import '../features/reminder/repositories/reminder_repository.dart';
import '../features/review/data/review_dao.dart';
import '../features/review/providers/review_provider.dart';
import '../features/review/repositories/review_repository.dart';
import '../features/shop_setting/data/shop_setting_dao.dart';
import '../features/shop_setting/providers/shop_setting_provider.dart';
import '../features/shop_setting/repositories/shop_setting_repository.dart';
import '../features/staff_examination/data/staff_examination_dao.dart';
import '../features/staff_examination/providers/staff_examination_provider.dart';
import '../features/staff_examination/repositories/staff_examination_repository.dart';
import '../features/time_slot/data/time_slot_dao.dart';
import '../features/time_slot/providers/time_slot_provider.dart';
import '../features/time_slot/repositories/time_slot_repository.dart';
import '../features/user_profile/data/user_profile_dao.dart';
import '../features/user_profile/providers/user_profile_provider.dart';
import '../features/user_profile/repositories/user_profile_repository.dart';
import 'app_route_parser.dart';
import 'app_router.dart';

class PetPalApp extends StatefulWidget {
  const PetPalApp({super.key});

  @override
  State<PetPalApp> createState() => _PetPalAppState();
}

class _PetPalAppState extends State<PetPalApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider(
              repository: AuthRepository(dao: AuthDao()),
            );

            provider.checkLoginStatus();

            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(
            repository: UserProfileRepository(dao: UserProfileDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PetProfileProvider(
            repository: PetProfileRepository(dao: PetProfileDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthRecordProvider(
            repository: HealthRecordRepository(dao: HealthRecordDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              BookingProvider(repository: BookingRepository(dao: BookingDao())),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(
            repository: PaymentRepository(
              dao: PaymentDao(),
              payOsClient: PayOsClient(
                credentials: const PayOsCredentials(
                  clientId: AppConfig.payOsClientId,
                  apiKey: AppConfig.payOsApiKey,
                  checksumKey: AppConfig.payOsChecksumKey,
                  returnUrl: AppConfig.payOsReturnUrl,
                  cancelUrl: AppConfig.payOsCancelUrl,
                ),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TimeSlotProvider(
            repository: TimeSlotRepository(dao: TimeSlotDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ReviewProvider(repository: ReviewRepository(dao: ReviewDao())),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffExaminationProvider(
            repository: StaffExaminationRepository(dao: StaffExaminationDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(
            repository: ReminderRepository(dao: ReminderDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminDashboardProvider(
            repository: AdminDashboardRepository(dao: AdminDashboardDao()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopSettingProvider(
            repository: ShopSettingRepository(dao: ShopSettingDao()),
          ),
        ),
      ],
      child: const _PetPalMaterialApp(),
    );
  }
}

class _PetPalMaterialApp extends StatefulWidget {
  const _PetPalMaterialApp();

  @override
  State<_PetPalMaterialApp> createState() => _PetPalMaterialAppState();
}

class _PetPalMaterialAppState extends State<_PetPalMaterialApp> {
  final AppRouter _routerDelegate = AppRouter();
  final AppRouteParser _routeParser = AppRouteParser();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    _routerDelegate.setAuthProvider(authProvider);

    return MaterialApp.router(
      title: 'PetPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeParser,
    );
  }
}
