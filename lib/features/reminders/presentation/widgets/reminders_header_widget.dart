import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// هيدر صفحة التذكيرات بتصميم Glassmorphism
class RemindersHeaderWidget extends StatelessWidget {
  const RemindersHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6BFF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                children: [
                  // صف العنوان مع زر الرجوع
                  _buildTitleRow(context),
                  SizedBox(height: 24.h),
                  // كروت الإحصائيات
                  _buildStatsRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        // زر الرجوع
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFF2F6BFF).withOpacity(0.1)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF2F6BFF),
              size: 18.sp,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // العنوان
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التذكيرات',
              style: GoogleFonts.cairo(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E2D4A),
              ),
            ),
            Text(
              'Medication Reminders',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A94A6),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Add Button
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2F6BFF), Color(0xFF4A7FFF)],
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F6BFF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard(value: '3', label: 'اليوم', color: const Color(0xFF2F6BFF)),
        SizedBox(width: 12.w),
        _statCard(value: '0', label: 'تم التناول', color: const Color(0xFF10B981)),
        SizedBox(width: 12.w),
        _statCard(value: '98%', label: 'الالتزام', color: const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _statCard({required String value, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2D4A).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
