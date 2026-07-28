import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';

class MedicationDetailScreen extends StatelessWidget {
  final ReminderEntity reminder;

  const MedicationDetailScreen({
    super.key,
    required this.reminder,
  });

  String _formatFullDate(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('EEEE, d MMMM yyyy - hh:mm a', 'ar').format(dt);
    } catch (_) {
      return isoTime;
    }
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return isoTime;
    }
  }

  (Color, String, IconData) _statusMeta(String status) {
    switch (status) {
      case 'Taken':
        return (const Color(0xFF08C75A), 'تم تناول الجرعة بنجاح', Icons.check_circle_rounded);
      case 'Skipped':
        return (const Color(0xFFFF4757), 'تم تخطي الجرعة', Icons.cancel_rounded);
      case 'Snoozed':
        return (const Color(0xFFFF9F43), 'مؤجل', Icons.snooze_rounded);
      default:
        return (const Color(0xFF5A97DF), 'موافي الموعد المجدول', Icons.alarm_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText, statusIcon) = _statusMeta(reminder.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'تفاصيل الدواء والجرعة',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Top Main Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.2),
                          statusColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      color: statusColor,
                      size: 38.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    reminder.title,
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      reminder.description!,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          statusText,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Action Buttons Section (If Pending)
            if (reminder.status == 'Pending') ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل الجرعة',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<RemindersCubit>().takeReminder(
                                    reminder.id,
                                    medicineId: reminder.relatedEntityId,
                                  );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: Text('تناول الجرعة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08C75A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<RemindersCubit>().snoozeReminder(reminder.id, 15);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.snooze_rounded),
                            label: Text('تأجيل 15 د', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF9F43),
                              side: const BorderSide(color: Color(0xFFFF9F43), width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Details Cards
            _detailTile(
              icon: Icons.calendar_today_rounded,
              iconColor: const Color(0xFF5A97DF),
              title: 'موعد الجرعة',
              subtitle: _formatFullDate(reminder.adjustedTime),
            ),
            SizedBox(height: 12.h),
            _detailTile(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFF08C75A),
              title: 'التكرار المجدول',
              subtitle: reminder == 'Medication'
                  ? 'جرعة يومية منتظمة'
                  : 'تذكير مجدول',
            ),
            SizedBox(height: 12.h),
            _detailTile(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: 'التعليمات والإرشادات',
              subtitle: 'تناول الدواء مع كوب ماء كبير بعد الوجبة مباشرة طبقاً لإرشادات الصيدلي.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
