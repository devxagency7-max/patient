import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_state.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_cubit.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_state.dart';
import 'package:pharmacare/features/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({super.key});

  void _navigateToRecords(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MedicalRecordsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () => _navigateToRecords(context),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF5FC),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          child: Icon(Icons.assignment_rounded, color: const Color(0xFF5A97DF), size: 20.r),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سجلك الصحي',
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'ملخص سجلاتك وقراءاتك الحالية',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.r,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      BlocBuilder<HealthCubit, HealthState>(
                        builder: (context, state) {
                          int count = 0;
                          if (state is HealthSuccess && state.history != null) {
                            count = state.history!.length;
                          }
                          return _statItem('$count', 'قراءة صحية', const Color(0xFF5A97DF));
                        },
                      ),
                      _divider(),
                      BlocBuilder<RemindersCubit, RemindersState>(
                        builder: (context, state) {
                          int count = 0;
                          if (state is RemindersLoaded) {
                            count = state.reminders.length + state.medicationPlans.length;
                          }
                          return _statItem('$count', 'أدوية نشطة', const Color(0xFF08C75A));
                        },
                      ),
                      _divider(),
                      BlocBuilder<MedicalRecordCubit, MedicalRecordState>(
                        builder: (context, state) {
                          int count = 0;
                          if (state is MedicalRecordLoaded) {
                            count = state.records.length;
                          }
                          return _statItem('$count', 'سجلات وملفات', const Color(0xFFFF9F43));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1.w,
      height: 32.h,
      color: const Color(0xFFE2E8F0),
    );
  }
}

