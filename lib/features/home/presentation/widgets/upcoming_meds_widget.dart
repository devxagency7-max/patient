import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_state.dart';
import 'package:pharmacare/features/reminders/presentation/screens/medication_detail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpcomingMedsWidget extends StatefulWidget {
  const UpcomingMedsWidget({super.key});

  @override
  State<UpcomingMedsWidget> createState() => _UpcomingMedsWidgetState();
}

class _UpcomingMedsWidgetState extends State<UpcomingMedsWidget> {
  RemindersLoaded? _lastLoaded;

  void _navigateToReminders(BuildContext context) {
    context.read<NavigationCubit>().setIndex(1);
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return isoTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأدوية القادمة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToReminders(context),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<RemindersCubit, RemindersState>(
            builder: (context, state) {
              if (state is RemindersLoaded) {
                _lastLoaded = state;
              }

              final loaded = state is RemindersLoaded ? state : _lastLoaded;

              if (loaded == null) {
                if (state is RemindersLoading) {
                  return Container(
                    height: 100.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                return _buildEmptyState(context);
              }

              // التذكيرات القادمة: المعلّقة فقط (Pending) التي لم يفت وقتها بعد،
              // مرتبة تصاعدياً حسب الموعد الأقرب أولاً.
              final now = DateTime.now();
              final pendingList =
                  loaded.reminders
                      .where(
                        (r) =>
                            r.status == 'Pending' &&
                            (DateTime.tryParse(r.adjustedTime)?.isAfter(now) ??
                                true),
                      )
                      .toList()
                    ..sort(
                      (a, b) =>
                          (DateTime.tryParse(a.adjustedTime) ?? DateTime(0))
                              .compareTo(
                                DateTime.tryParse(b.adjustedTime) ??
                                    DateTime(0),
                              ),
                    );
              List<ReminderEntity> displayReminders = [...pendingList];

              // إذا لم تكن هناك تذكيرات منفردة وكان هناك خطط علاجية مسجلة
              if (displayReminders.isEmpty &&
                  loaded.medicationPlans.isNotEmpty) {
                for (final plan in loaded.medicationPlans) {
                  displayReminders.add(
                    ReminderEntity(
                      id: plan.id,
                      title: plan.medicineName,
                      description:
                          'الجرعة: ${plan.dosage} - ${plan.instructions}',
                      adjustedTime: DateTime.now().toIso8601String(),
                      status: 'Pending',
                    ),
                  );
                }
              }

              if (displayReminders.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: displayReminders.take(3).map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _reminderCard(context, item),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              size: 36.r,
              color: const Color(0xFF5A97DF),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد أدوية قادمة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'يمكنك إضافة تذكير جديد لموعد أدويتك',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 14.h),
          ElevatedButton.icon(
            onPressed: () => _navigateToReminders(context),
            icon: Icon(Icons.add_alarm_rounded, size: 18.r),
            label: Text(
              'إضافة تذكير',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A97DF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(BuildContext context, ReminderEntity reminder) {
    final bool isTaken = reminder.status == 'Taken';
    final Color statusColor = isTaken
        ? const Color(0xFF08C75A)
        : const Color(0xFF5A97DF);
    final Color statusBg = isTaken
        ? const Color(0xFFEAF8F0)
        : const Color(0xFFEEF5FC);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicationDetailScreen(reminder: reminder),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FC),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: const Color(0xFF5A97DF),
                    size: 26.r,
                  ),
                ),
                Positioned(
                  top: -4.r,
                  right: -4.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '1 كبسولة',
                      style: GoogleFonts.cairo(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A97DF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'جرعة #1',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5A97DF),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            reminder.description!,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(reminder.adjustedTime),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    isTaken ? 'تم التناول' : 'قادم',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
