import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_state.dart';
import 'package:pharmacare/features/reminders/presentation/screens/medication_detail_screen.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final cubit = context.read<RemindersCubit>();
      cubit.fetchRemindersAndPlans();
      return const RemindersView();
    } catch (_) {
      return BlocProvider(
        create: (context) => getIt<RemindersCubit>()..fetchRemindersAndPlans(),
        child: const RemindersView(),
      );
    }
  }
}

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  void _showAddReminderSheet(BuildContext context) {
    final cubit = context.read<RemindersCubit>();
    final titleController = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
    String selectedType = 'Medication';
    String selectedFrequency = 'Once';
    final intervalHoursController = TextEditingController(text: '8');

    const typeOptions = {
      'Medication': 'دواء',
      'Lab': 'تحليل',
      'DoctorVisit': 'زيارة طبيب',
      'Scan': 'أشعة',
      'Other': 'أخرى',
    };
    const frequencyOptions = {
      'Once': 'مرة واحدة',
      'Daily': 'يومي',
      'EveryXHours': 'كل عدد ساعات',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة تذكير جديد',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2D4A),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.cairo(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'عنوان التذكير (مثال: دواء الضغط)',
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          isExpanded: true,
                          items: typeOptions.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() => selectedType = value);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedFrequency,
                          isExpanded: true,
                          items: frequencyOptions.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() => selectedFrequency = value);
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedFrequency == 'EveryXHours') ...[
                      SizedBox(height: 12.h),
                      TextField(
                        controller: intervalHoursController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'كل كام ساعة',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: sheetContext,
                          initialDate: selectedTime,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (date == null || !sheetContext.mounted) return;
                        final time = await showTimePicker(
                          context: sheetContext,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        );
                        if (time != null) {
                          setSheetState(() {
                            selectedTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              DateFormat(
                                'yyyy-MM-dd hh:mm a',
                              ).format(selectedTime),
                              style: GoogleFonts.cairo(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          cubit.createReminder(
                            type: selectedType,
                            title: titleController.text.trim(),
                            frequencyType: selectedFrequency,
                            intervalHours: selectedFrequency == 'EveryXHours'
                                ? int.tryParse(
                                    intervalHoursController.text.trim(),
                                  )
                                : null,
                            startTime: selectedTime.toUtc().toIso8601String(),
                          );
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'حفظ التذكير',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddReminderSheet(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundBlob(),
          BlocConsumer<RemindersCubit, RemindersState>(
            listener: (context, state) {
              if (state is RemindersOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is RemindersError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is RemindersLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is RemindersLoaded) {
                final todayReminders = state.reminders
                    .where((r) => !_isPastDate(r.adjustedTime))
                    .toList();
                final pastReminders = state.reminders
                    .where(
                      (r) =>
                          _isPastDate(r.adjustedTime) || r.status != 'Pending',
                    )
                    .toList();

                final takenToday = todayReminders
                    .where((r) => r.status == 'Taken')
                    .length;
                final totalToday = todayReminders.length;
                final compliance = totalToday > 0
                    ? (takenToday / totalToday * 100).toStringAsFixed(0)
                    : '100';

                return Column(
                  children: [
                    _buildHeader(
                      totalToday.toString(),
                      takenToday.toString(),
                      '$compliance%',
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context
                            .read<RemindersCubit>()
                            .fetchRemindersAndPlans(),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPlansSection(state.medicationPlans),
                              SizedBox(height: 24.h),
                              _buildTodaySection(todayReminders),
                              SizedBox(height: 24.h),
                              _buildHistorySection(pastReminders),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (state is RemindersError) {
                return _buildErrorState(state.message);
              }

              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob() {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          left: -50.w,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2F6BFF).withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          top: 300.h,
          right: -80.w,
          child: Container(
            width: 250.w,
            height: 250.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A7FFF).withOpacity(0.1),
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

  Widget _buildHeader(String todayCount, String takenCount, String compliance) {
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
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التذكيرات والجرعات',
                            style: GoogleFonts.cairo(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E2D4A),
                            ),
                          ),
                          Text(
                            'Medication Plans & Tracker',
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
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      _statCard(
                        value: todayCount,
                        label: 'اليوم',
                        color: const Color(0xFF2F6BFF),
                      ),
                      SizedBox(width: 12.w),
                      _statCard(
                        value: takenCount,
                        label: 'تم التناول',
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 12.w),
                      _statCard(
                        value: compliance,
                        label: 'الالتزام',
                        color: const Color(0xFFF59E0B),
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

  Widget _statCard({
    required String value,
    required String label,
    required Color color,
  }) {
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

  Widget _buildPlansSection(List<MedicationPlanEntity> plans) {
    if (plans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخطط العلاجية النشطة',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2D4A),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: plans.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Container(
                width: 220.w,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.medicineName,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'الجرعة: ${plan.dosage}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                    ),
                    const Spacer(),
                    Text(
                      plan.instructions,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySection(List<ReminderEntity> reminders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تذكيرات اليوم',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2D4A),
          ),
        ),
        SizedBox(height: 12.h),
        if (reminders.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'لا توجد تذكيرات مجدولة لليوم',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13.sp),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _reminderCard(context, reminder);
            },
          ),
      ],
    );
  }

  Widget _buildHistorySection(List<ReminderEntity> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تذكيرات سابقة وحالات أخرى',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2D4A),
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final reminder = history[index];
            final Color statusColor = _getStatusColor(reminder.status);
            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      reminder.status == 'Taken'
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: statusColor,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          _formatTime(reminder.adjustedTime),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _translateStatus(reminder.status),
                      style: GoogleFonts.cairo(
                        color: statusColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _reminderCard(BuildContext context, ReminderEntity reminder) {
    final bool isHandled = reminder.status != 'Pending';
    final Color statusColor = _getStatusColor(reminder.status);

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
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isHandled
                        ? statusColor.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    reminder.status == 'Taken'
                        ? Icons.check_rounded
                        : reminder.status == 'Skipped'
                        ? Icons.close_rounded
                        : Icons.medication_rounded,
                    color: isHandled ? statusColor : AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                Positioned(
                  top: -4.r,
                  right: -4.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '1 جرعة',
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
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2D4A),
                      decoration: reminder.status == 'Taken'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'جرعة #1',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        if (reminder.description != null &&
                            reminder.description!.isNotEmpty) ...[
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 80.w),
                            child: Text(
                              reminder.description!,
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Icon(
                          Icons.access_time_rounded,
                          size: 11.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _formatTime(reminder.adjustedTime),
                          style: GoogleFonts.poppins(
                            fontSize: 10.5.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isHandled) ...[
              _actionButton(
                icon: Icons.check_rounded,
                color: const Color(0xFF10B981),
                onTap: () => context.read<RemindersCubit>().takeReminder(
                  reminder.id,
                  medicineId: reminder.relatedEntityId,
                ),
              ),
              SizedBox(width: 6.w),
              _actionButton(
                icon: Icons.snooze_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => context.read<RemindersCubit>().snoozeReminder(
                  reminder.id,
                  15,
                ),
              ),
              SizedBox(width: 6.w),
              _actionButton(
                icon: Icons.close_rounded,
                color: Colors.grey,
                onTap: () =>
                    context.read<RemindersCubit>().skipReminder(reminder.id),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _translateStatus(reminder.status),
                  style: GoogleFonts.cairo(
                    color: statusColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'فشل تحميل التذكيرات',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(message, style: GoogleFonts.cairo(color: Colors.grey)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () =>
                context.read<RemindersCubit>().fetchRemindersAndPlans(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  bool _isPastDate(String isoStr) {
    try {
      final date = DateTime.parse(isoStr).toLocal();
      final now = DateTime.now();
      return date.year < now.year ||
          (date.year == now.year && date.month < now.month) ||
          (date.year == now.year &&
              date.month == now.month &&
              date.day < now.day);
    } catch (_) {
      return false;
    }
  }

  String _formatTime(String isoStr) {
    try {
      final date = DateTime.parse(isoStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return isoStr;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Taken':
        return 'تم التناول';
      case 'Skipped':
        return 'تم التخطي';
      case 'Snoozed':
        return 'مؤجل';
      case 'Pending':
        return 'قادم';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Taken':
        return const Color(0xFF10B981);
      case 'Skipped':
        return const Color(0xFFEF4444);
      case 'Snoozed':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }
}
