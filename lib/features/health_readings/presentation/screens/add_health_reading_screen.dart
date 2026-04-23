import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/health_readings/presentation/screens/reading_input_screen.dart';

/// أنواع القراءات الصحية
enum ReadingType { bloodPressure, bloodSugar, weight, temperature }

/// بيانات كل نوع قراءة
class ReadingTypeInfo {
  final ReadingType type;
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Color color;

  const ReadingTypeInfo({
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.color,
  });
}

/// صفحة اختيار نوع القراءة الصحية - Add Health Reading Screen
class AddHealthReadingScreen extends StatelessWidget {
  const AddHealthReadingScreen({super.key});

  static const List<ReadingTypeInfo> _readingTypes = [
    ReadingTypeInfo(
      type: ReadingType.bloodPressure,
      titleAr: 'ضغط الدم',
      titleEn: 'Blood Pressure',
      icon: Icons.favorite_rounded,
      color: Color(0xFFFF4757),
    ),
    ReadingTypeInfo(
      type: ReadingType.bloodSugar,
      titleAr: 'السكر',
      titleEn: 'Blood Sugar',
      icon: Icons.show_chart_rounded,
      color: Color(0xFFFF9F43),
    ),
    ReadingTypeInfo(
      type: ReadingType.weight,
      titleAr: 'الوزن',
      titleEn: 'Weight',
      icon: Icons.monitor_weight_outlined,
      color: Color(0xFF00B894),
    ),
    ReadingTypeInfo(
      type: ReadingType.temperature,
      titleAr: 'الحرارة',
      titleEn: 'Temperature',
      icon: Icons.thermostat_rounded,
      color: Color(0xFF00C48C),
    ),
  ];

  void _navigateToReading(BuildContext context, ReadingTypeInfo info) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReadingInputScreen(readingInfo: info),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر نوع القراءة:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Grid 2x2
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _readingTypes.map((info) {
                        return _buildReadingCard(context, info);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الهيدر
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F6BFF), Color(0xFF43D4A0)],
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إضافة قراءة صحية',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Add Health Reading',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
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

  /// كارد نوع القراءة
  Widget _buildReadingCard(BuildContext context, ReadingTypeInfo info) {
    return GestureDetector(
      onTap: () => _navigateToReading(context, info),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(info.icon, color: info.color, size: 28),
            ),
            const SizedBox(height: 14),
            // النص العربي
            Text(
              info.titleAr,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            // النص الإنجليزي
            Text(
              info.titleEn,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
