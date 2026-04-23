import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

/// صفحة الملف الطبي - Profile / Medical Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // الهيدر ثابت في الأعلى
          _buildHeader(context),
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // القائمة
                  _buildMenuList(),
                  const SizedBox(height: 20),
                  // ملخص صحي
                  _buildHealthSummary(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الهيدر بالـ Gradient + بيانات المريض
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F6BFF), Color(0xFF6FA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Column(
            children: [
              // العنوان
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الملف الطبي',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // الصورة + البيانات في صف واحد
              Row(
                children: [
                  // الصورة الشخصية
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // الاسم والبيانات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أحمد محمد',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'رقم المريض #PAT-2024-001',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+20 123 456 7890',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.cake_outlined,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '35 سنة',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// قائمة الأقسام
  Widget _buildMenuList() {
    final menuItems = [
      _MenuItem(
        icon: Icons.assignment_outlined,
        color: const Color(0xFF2F6BFF),
        titleAr: 'السجل الطبي',
        titleEn: 'Medical History',
      ),
      _MenuItem(
        icon: Icons.favorite_outline_rounded,
        color: const Color(0xFFFF4757),
        titleAr: 'الأمراض المزمنة',
        titleEn: 'Chronic Diseases',
      ),
      _MenuItem(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFFF9F43),
        titleAr: 'الحساسية',
        titleEn: 'Allergies',
      ),
      _MenuItem(
        icon: Icons.medication_outlined,
        color: const Color(0xFF2F6BFF),
        titleAr: 'قائمة الأدوية',
        titleEn: 'Medications',
      ),
      _MenuItem(
        icon: Icons.show_chart_rounded,
        color: const Color(0xFF00C48C),
        titleAr: 'القراءات الصحية',
        titleEn: 'Health Readings',
      ),
      _MenuItem(
        icon: Icons.science_outlined,
        color: const Color(0xFF8B5CF6),
        titleAr: 'نتائج التحاليل',
        titleEn: 'Lab Results',
      ),
      _MenuItem(
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFFF4757),
        titleAr: 'معلومات الطوارئ',
        titleEn: 'Emergency Info',
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        color: const Color(0xFF8A94A6),
        titleAr: 'الإعدادات',
        titleEn: 'Settings',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: menuItems.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            // TODO: فتح الصفحة الخاصة
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // الأيقونة
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 14),
                // العنوان
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titleAr,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.titleEn,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // سهم
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ملخص صحي
  Widget _buildHealthSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E2D4A), Color(0xFF253754)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2D4A).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص صحي',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _healthStat(
                  icon: Icons.bloodtype_outlined,
                  label: 'فصيلة الدم',
                  value: 'O+',
                  color: const Color(0xFFFF4757),
                ),
                _healthStat(
                  icon: Icons.height_rounded,
                  label: 'الطول',
                  value: '175 cm',
                  color: const Color(0xFF2F6BFF),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _healthStat(
                  icon: Icons.monitor_weight_outlined,
                  label: 'الوزن',
                  value: '75 kg',
                  color: const Color(0xFF00C48C),
                ),
                _healthStat(
                  icon: Icons.speed_rounded,
                  label: 'BMI',
                  value: '24.5',
                  color: const Color(0xFFFF9F43),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _healthStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بيانات عنصر القائمة
class _MenuItem {
  final IconData icon;
  final Color color;
  final String titleAr;
  final String titleEn;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.titleAr,
    required this.titleEn,
  });
}
