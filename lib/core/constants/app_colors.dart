import 'package:flutter/material.dart';

/// ألوان التطبيق الأساسية - PharmaCare Design System
class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF2F6BFF);
  static const Color primaryLight = Color(0xFF6FA4FF);
  static const Color primaryDark = Color(0xFF1F55D8);

  // ألوان الخلفية
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F7FB);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ألوان إضافية
  static const Color success = Color(0xFF00C48C);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFBE21);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF2F6BFF), Color(0xFF6FA4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
