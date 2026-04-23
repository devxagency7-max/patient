import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';

/// NavBar مخصص بتصميم فقاعة متحركة (Animated Bubble)
/// يعمل مع Riverpod بدلاً من Provider
class CustomNavBar extends ConsumerWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final displayWidth = MediaQuery.of(context).size.width;
    final navBarWidth = displayWidth - 40; // padding 20 * 2
    final itemWidth = navBarWidth / 5;
    const bubbleWidth = 50.0;
    const bubbleHeight = 50.0;

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // الفقاعة المتحركة
          AnimatedPositionedDirectional(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            start: (selectedIndex * itemWidth) + (itemWidth - bubbleWidth) / 2,
            top: (70 - bubbleHeight) / 2,
            child: Container(
              width: bubbleWidth,
              height: bubbleHeight,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          // الأيقونات
          Row(
            children: [
              _navItem(
                context,
                ref,
                Icons.home_rounded,
                0,
                itemWidth,
                'الرئيسية',
              ),
              _navItem(
                context,
                ref,
                Icons.notifications_none_rounded,
                1,
                itemWidth,
                'التذكيرات',
              ),
              _navItem(
                context,
                ref,
                Icons.medication_outlined,
                2,
                itemWidth,
                'طلب دواء',
              ),
              _navItem(
                context,
                ref,
                Icons.chat_bubble_outline_rounded,
                3,
                itemWidth,
                'المعالجة',
              ),
              _navItem(
                context,
                ref,
                Icons.person_outline_rounded,
                4,
                itemWidth,
                'حسابي',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    int index,
    double width,
    String label,
  ) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(selectedNavIndexProvider.notifier).setIndex(index);
      },
      child: Container(
        width: width,
        height: 70,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 26,
            ),
            if (!isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
