import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

/// بيانات التذكير
class ReminderData {
  final String name;
  final String dose;
  final String time;
  bool isTaken;
  bool isDismissed;

  ReminderData({
    required this.name,
    required this.dose,
    required this.time,
    this.isTaken = false,
    this.isDismissed = false,
  });
}

/// قسم تذكيرات اليوم
class TodayRemindersWidget extends StatefulWidget {
  const TodayRemindersWidget({super.key});

  @override
  State<TodayRemindersWidget> createState() => _TodayRemindersWidgetState();
}

class _TodayRemindersWidgetState extends State<TodayRemindersWidget> {
  final List<ReminderData> _reminders = [
    ReminderData(name: 'أسبرين', dose: '100mg', time: '10:00 AM'),
    ReminderData(name: 'ميتفورمين', dose: '500mg', time: '02:00 PM'),
    ReminderData(name: 'أوميجا 3', dose: '1000mg', time: '08:00 PM'),
  ];

  void _markAsTaken(int index) {
    setState(() {
      _reminders[index].isTaken = true;
    });
  }

  void _dismissReminder(int index) {
    setState(() {
      _reminders[index].isDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تذكيرات اليوم',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E2D4A),
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F6BFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(_reminders.length, (index) {
            return FadeInUp(
              duration: Duration(milliseconds: 400 + (index * 100)),
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _reminderCard(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _reminderCard(int index) {
    final reminder = _reminders[index];
    final bool isHandled = reminder.isTaken || reminder.isDismissed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: reminder.isTaken
              ? const Color(0xFF10B981).withOpacity(0.3)
              : reminder.isDismissed
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: reminder.isTaken
                          ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                          : reminder.isDismissed
                              ? [const Color(0xFFEF4444), const Color(0xFFF87171)]
                              : [const Color(0xFF2F6BFF).withOpacity(0.1), const Color(0xFF4A7FFF).withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    reminder.isTaken
                        ? Icons.check_rounded
                        : reminder.isDismissed
                            ? Icons.close_rounded
                            : Icons.medication_rounded,
                    color: isHandled ? Colors.white : const Color(0xFF2F6BFF),
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.name,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2D4A),
                          decoration: isHandled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            reminder.dose,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2F6BFF),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            width: 3.w,
                            height: 3.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8A94A6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(Icons.access_time_rounded, size: 12.sp, color: const Color(0xFF8A94A6)),
                          SizedBox(width: 4.w),
                          Text(
                            reminder.time,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8A94A6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                if (!isHandled) ...[
                  _actionButton(
                    icon: Icons.check_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => _markAsTaken(index),
                  ),
                  SizedBox(width: 10.w),
                  _actionButton(
                    icon: Icons.close_rounded,
                    color: const Color(0xFF8A94A6),
                    onTap: () => _dismissReminder(index),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: reminder.isTaken
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      reminder.isTaken ? 'تم' : 'تجاهل',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: reminder.isTaken ? const Color(0xFF10B981) : Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}
