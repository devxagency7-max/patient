import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:pharmacare/features/health_readings/presentation/screens/add_health_reading_screen.dart';
import 'package:pharmacare/features/prescription/presentation/screens/upload_prescription_screen.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickActionItem(
                context: context,
                icon: Icons.emergency_rounded,
                label: 'طوارئ',
                color: const Color(0xFFFF4757),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EmergencyScreen()));
                },
              ),
              _quickActionItem(
                context: context,
                icon: Icons.medication_rounded,
                label: 'أدويتي',
                color: const Color(0xFF08C75A),
                onTap: () {
                  context.read<NavigationCubit>().setIndex(1);
                },
              ),
              _quickActionItem(
                context: context,
                icon: Icons.monitor_heart_rounded,
                label: 'إضافة قراءة',
                color: const Color(0xFF5A97DF),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddHealthReadingScreen()));
                },
              ),
              _quickActionItem(
                context: context,
                icon: Icons.note_add_rounded,
                label: 'رفع روشتة',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadPrescriptionScreen(isOrderMode: false)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: color, size: 30.r),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}


