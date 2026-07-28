import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

/// صفحة اختيار نوع القراءة الصحية - Add Health Reading Screen بنمط زجاجي
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
          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      body: Stack(
        children: [
          _buildMeshBackground(),
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          'اختر نوع القراءة التي تود إضافتها:',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Grid 2x2
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.r,
                          crossAxisSpacing: 16.r,
                          childAspectRatio: 0.95,
                          physics: const BouncingScrollPhysics(),
                          children: List.generate(_readingTypes.length, (index) {
                            final info = _readingTypes[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: index * 100),
                              child: _buildReadingCard(context, info),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// خلفية الميش المتدرجة
  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF43D4A0).withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  /// الهيدر الزجاجي
  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E40AF).withOpacity(0.9),
                const Color(0xFF1E40AF).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة قراءة صحية',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Record Health Vitals',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// كارد نوع القراءة (زجاجي بريميوم)
  Widget _buildReadingCard(BuildContext context, ReadingTypeInfo info) {
    return GestureDetector(
      onTap: () => _navigateToReading(context, info),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: info.color.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الأيقونة مع توهج خلفي
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        color: info.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(info.icon, color: info.color, size: 32.r),
                  ],
                ),
                SizedBox(height: 16.h),
                // النصوص
                Text(
                  info.titleAr,
                  style: GoogleFonts.cairo(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  info.titleEn,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
