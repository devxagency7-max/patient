import 'package:flutter/material.dart';

/// بيانات كل صفحة في الـ Onboarding
class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;

  const OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });
}
