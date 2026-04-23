import 'package:flutter/material.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

/// مؤشر النقاط لعرض الصفحة الحالية في الـ Onboarding
class OnboardingDotsIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingDotsIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
