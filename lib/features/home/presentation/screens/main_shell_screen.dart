import 'package:flutter/material.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/core/widgets/custom_nav_bar.dart';
import 'package:pharmacare/features/chat/presentation/screens/chat_screen.dart';
import 'package:pharmacare/features/devices/data/services/device_push_service.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:pharmacare/features/home/presentation/screens/home_screen.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_cubit.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/order_medicine_screen.dart';
import 'package:pharmacare/features/profile/presentation/screens/profile_screen.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:pharmacare/features/telemetry/data/services/telemetry_service.dart';

/// الشاشة الرئيسية اللي بتحتوي على الـ NavBar وبتبدل بين الصفحات
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;

  // تتاخذ مرة واحدة لحياة الـ shell كله، مش كل مرة الـ HomeScreen بيتعمل له build.
  late final HealthCubit _healthCubit;
  late final NotificationCubit _notificationCubit;
  late final RemindersCubit _remindersCubit;
  late final MedicalRecordCubit _medicalRecordCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(
      initialPage: context.read<NavigationCubit>().state,
    );

    _healthCubit = sl<HealthCubit>()..fetchHistory();
    _notificationCubit = sl<NotificationCubit>()..fetchUnreadCount();
    _remindersCubit = sl<RemindersCubit>()..fetchRemindersAndPlans();
    _medicalRecordCubit = sl<MedicalRecordCubit>()..fetchMedicalRecords();

    // جلب بيانات المستخدم عند فتح الشاشة الرئيسية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().fetchProfile();
    });
    // تسجيل FCM token في الخلفية (upsert آمن التكرار) — بدون واجهة مستخدم.
    sl<DevicePushService>().registerCurrentDevice();
    // نبضة تتبّع استخدام كل 60 ثانية طالما التطبيق في المقدمة.
    sl<TelemetryService>().startHeartbeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final telemetry = sl<TelemetryService>();
    if (state == AppLifecycleState.resumed) {
      telemetry.startHeartbeat();
    } else if (state == AppLifecycleState.paused) {
      telemetry.stopHeartbeat();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    sl<TelemetryService>().stopHeartbeat();
    _healthCubit.close();
    _notificationCubit.close();
    _remindersCubit.close();
    _medicalRecordCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الصفحات الخمسة
    final List<Widget> pages = const [
      HomeScreen(),
      RemindersScreen(),
      OrderMedicineScreen(),
      ChatScreen(),
      ProfileScreen(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _healthCubit),
        BlocProvider.value(value: _notificationCubit),
        BlocProvider.value(value: _remindersCubit),
        BlocProvider.value(value: _medicalRecordCubit),
      ],
      child: BlocListener<NavigationCubit, int>(
        listener: (context, selectedIndex) {
          if (_pageController.hasClients &&
              _pageController.page?.round() != selectedIndex) {
            _pageController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        child: BlocBuilder<NavigationCubit, int>(
          builder: (context, selectedIndex) {
            return Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
              extendBody: true,
              bottomNavigationBar: const CustomNavBar(),
            );
          },
        ),
      ),
    );
  }
}
