import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacare/core/widgets/custom_nav_bar.dart';
import 'package:pharmacare/features/chat/presentation/screens/chat_screen.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:pharmacare/features/home/presentation/screens/home_screen.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/order_medicine_screen.dart';
import 'package:pharmacare/features/profile/presentation/screens/profile_screen.dart';
import 'package:pharmacare/features/reminders/presentation/screens/reminders_screen.dart';

/// الشاشة الرئيسية اللي بتحتوي على الـ NavBar وبتبدل بين الصفحات
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    // الصفحات الخمسة
    final List<Widget> pages = const [
      HomeScreen(),
      RemindersScreen(),
      OrderMedicineScreen(),
      ChatScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      extendBody: true,
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
