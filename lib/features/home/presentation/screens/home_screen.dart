import 'package:flutter/material.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/home/presentation/widgets/home_header_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/upcoming_meds_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/medical_reminder_card.dart';
import 'package:pharmacare/features/home/presentation/widgets/health_record_card.dart';

/// الصفحة الرئيسية - Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // الهيدر ثابت في الأعلى
          const HomeHeaderWidget(),
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 24),

                  // الإجراءات السريعة
                  QuickActionsWidget(),

                  SizedBox(height: 24),

                  // الأدوية القادمة
                  UpcomingMedsWidget(),

                  SizedBox(height: 20),

                  // التذكير الطبي
                  MedicalReminderCard(),

                  SizedBox(height: 20),

                  // السجل الصحي
                  HealthRecordCard(),

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
