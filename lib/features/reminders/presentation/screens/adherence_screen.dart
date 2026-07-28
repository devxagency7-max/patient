import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_log_entity.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/adherence_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/adherence_state.dart';

class AdherenceScreen extends StatelessWidget {
  const AdherenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdherenceCubit>()..fetchAdherence(),
      child: const _AdherenceView(),
    );
  }
}

class _AdherenceView extends StatefulWidget {
  const _AdherenceView();

  @override
  State<_AdherenceView> createState() => _AdherenceViewState();
}

class _AdherenceViewState extends State<_AdherenceView> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('الالتزام الدوائي', style: GoogleFonts.cairo(color: const Color(0xFF1E2D4A), fontWeight: FontWeight.w900, fontSize: 18.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AdherenceCubit, AdherenceState>(
        builder: (context, state) {
          if (state is AdherenceLoading || state is AdherenceInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AdherenceError) {
            return Center(child: Text('حدث خطأ أثناء تحميل البيانات', style: GoogleFonts.cairo(color: Colors.grey)));
          }

          if (state is AdherenceLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<AdherenceCubit>().fetchAdherence(days: _days),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.r),
                children: [
                  _buildDaySelector(context),
                  SizedBox(height: 20.h),
                  _buildScoreCard(state.summary),
                  SizedBox(height: 24.h),
                  Text('آخر السجلات', style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A))),
                  SizedBox(height: 12.h),
                  if (state.logs.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(child: Text('لا توجد سجلات حديثة', style: GoogleFonts.cairo(color: Colors.grey))),
                    )
                  else
                    ...state.logs.map(_logTile),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    return Row(
      children: [10, 30, 90].map((d) {
        final selected = _days == d;
        return Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: GestureDetector(
            onTap: () {
              setState(() => _days = d);
              context.read<AdherenceCubit>().fetchAdherence(days: d);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: selected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
              ),
              child: Text(
                '$d يوم',
                style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold, color: selected ? Colors.white : const Color(0xFF64748B)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoreCard(AdherenceSummaryEntity summary) {
    final percentage = summary.adherencePercentage.clamp(0, 100);
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16)],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140.r,
            height: 140.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140.r,
                  height: 140.r,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 80 ? AppColors.success : (percentage >= 50 ? AppColors.warning : AppColors.error),
                    ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E2D4A)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn('${summary.totalTaken}', 'تم أخذها', AppColors.success),
              _statColumn('${summary.totalMissed}', 'فائتة', AppColors.error),
              _statColumn('${summary.totalSkipped}', 'متخطاة', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: color)),
        SizedBox(height: 4.h),
        Text(label, style: GoogleFonts.cairo(fontSize: 11.sp, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _logTile(MedicationLogEntity log) {
    final statusInfo = switch (log.status) {
      1 => ('تم الأخذ', AppColors.success, Icons.check_circle_rounded),
      2 => ('فائتة', AppColors.error, Icons.cancel_rounded),
      3 => ('متخطاة', AppColors.warning, Icons.remove_circle_rounded),
      _ => ('غير معروف', Colors.grey, Icons.help_rounded),
    };

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(statusInfo.$3, color: statusInfo.$2, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              statusInfo.$1,
              style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E2D4A)),
            ),
          ),
          Text(
            '${log.scheduledAt.hour.toString().padLeft(2, '0')}:${log.scheduledAt.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.cairo(fontSize: 11.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
