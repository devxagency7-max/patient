import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationCubit>().state;
    return Container(
      height: 70.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(35.r),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navBarWidth = constraints.maxWidth;
              final itemWidth = navBarWidth / 5;
              final bubbleSize = 50.r;

              return Stack(
                children: [
                  AnimatedPositionedDirectional(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    start:
                        (selectedIndex * itemWidth) +
                        (itemWidth - bubbleSize) / 2,
                    top: (constraints.maxHeight - bubbleSize) / 2,
                    child: Container(
                      width: bubbleSize,
                      height: bubbleSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _navItem(
                        context,
                        Icons.home_rounded,
                        0,
                        itemWidth,
                        'الرئيسية',
                      ),
                      _navItem(
                        context,
                        Icons.notifications_none_rounded,
                        1,
                        itemWidth,
                        'التذكيرات',
                      ),
                      _navItem(
                        context,
                        Icons.medication_outlined,
                        2,
                        itemWidth,
                        'طلب دواء',
                      ),
                      _navItem(
                        context,
                        Icons.chat_bubble_outline_rounded,
                        3,
                        itemWidth,
                        'المعالجة',
                      ),
                      _navItem(
                        context,
                        Icons.person_outline_rounded,
                        4,
                        itemWidth,
                        'حسابي',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    int index,
    double width,
    String label,
  ) {
    final selectedIndex = context.watch<NavigationCubit>().state;
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().setIndex(index),
      child: Container(
        width: width,
        height: 70.h,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 26.r,
            ),
          ],
        ),
      ),
    );
  }
}
