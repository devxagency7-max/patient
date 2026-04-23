import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

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
    ReminderData(name: 'أسبرين', dose: '100mg', time: '10:00'),
    ReminderData(name: 'ميتفورمين', dose: '500mg', time: '14:00'),
    ReminderData(name: 'أوميجا 3', dose: '1000mg', time: '20:00'),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تذكيرات اليوم',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_reminders.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _reminders.length - 1 ? 12 : 0,
              ),
              child: _reminderCard(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _reminderCard(int index) {
    final reminder = _reminders[index];
    final bool isHandled = reminder.isTaken || reminder.isDismissed;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isHandled ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: reminder.isTaken
                ? const Color(0xFF00C48C).withValues(alpha: 0.3)
                : reminder.isDismissed
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // أيقونة الجرس
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reminder.isTaken
                    ? const Color(0xFF00C48C).withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                reminder.isTaken
                    ? Icons.check_rounded
                    : Icons.notifications_active_outlined,
                color: reminder.isTaken
                    ? const Color(0xFF00C48C)
                    : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // معلومات الدواء
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.name,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: isHandled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.dose,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // أزرار الأكشن
            if (!isHandled) ...[
              // زر تم التناول (علامة صح خضراء)
              _actionButton(
                icon: Icons.check_rounded,
                color: const Color(0xFF00C48C),
                bgColor: const Color(0xFF00C48C).withValues(alpha: 0.1),
                onTap: () => _markAsTaken(index),
              ),
              const SizedBox(width: 8),
              // زر التخطي (X رمادي)
              _actionButton(
                icon: Icons.close_rounded,
                color: Colors.grey.shade400,
                bgColor: Colors.grey.withValues(alpha: 0.08),
                onTap: () => _dismissReminder(index),
              ),
            ] else ...[
              // حالة تم التناول أو تم التخطي
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: reminder.isTaken
                      ? const Color(0xFF00C48C).withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reminder.isTaken ? 'تم ✓' : 'تخطي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: reminder.isTaken
                        ? const Color(0xFF00C48C)
                        : Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
