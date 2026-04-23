import 'package:flutter/material.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/reminders/presentation/widgets/reminders_header_widget.dart';
import 'package:pharmacare/features/reminders/presentation/widgets/today_reminders_widget.dart';
import 'package:pharmacare/features/reminders/presentation/widgets/reminder_history_widget.dart';

/// صفحة التذكيرات - Reminders Screen
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // الهيدر ثابت في الأعلى
          const RemindersHeaderWidget(),
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 24),

                  // تذكيرات اليوم
                  TodayRemindersWidget(),

                  SizedBox(height: 28),

                  // السجل السابق
                  ReminderHistoryWidget(),

                  // مسافة إضافية للـ NavBar
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
