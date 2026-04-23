import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/onboarding/data/models/onboarding_page_data.dart';

/// ويدجت صفحة واحدة من الـ Onboarding
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // أيقونة في كارد مع Gradient خلفية
          _buildIconCard(),

          const SizedBox(height: 48),

          // العنوان بالعربي
          Text(
            data.titleAr,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          // العنوان بالإنجليزي
          Text(
            data.titleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // الوصف بالعربي
          Text(
            data.descriptionAr,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),

          const SizedBox(height: 8),

          // الوصف بالإنجليزي
          Text(
            data.descriptionEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  /// أيقونة داخل كارد أبيض مع خلفية Gradient خفيفة
  Widget _buildIconCard() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: data.iconColor.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: data.iconColor.withValues(alpha: 0.05),
            blurRadius: 80,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خلفية Gradient خفيفة
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                colors: [
                  data.iconColor.withValues(alpha: 0.05),
                  data.iconColor.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // الأيقونة
          Icon(data.icon, size: 72, color: data.iconColor),
        ],
      ),
    );
  }
}
