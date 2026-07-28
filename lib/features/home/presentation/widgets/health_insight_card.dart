import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/home/presentation/cubit/health_insight_cubit.dart';
import 'package:pharmacare/features/home/presentation/cubit/health_insight_state.dart';
import 'package:shimmer/shimmer.dart';

class HealthInsightCard extends StatelessWidget {
  const HealthInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthInsightCubit, HealthInsightState>(
      builder: (context, state) {
        if (state is HealthInsightLoading) {
          return _buildShimmer();
        }

        if (state is HealthInsightLoaded) {
          final insight = state.insight;
          final riskColor = _getRiskColor(insight.riskLevel);
          final riskText = _translateRiskLevel(insight.riskLevel);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A97DF).withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEEF5FC), Color(0xFFE2E8F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: Color(0xFF5A97DF), size: 24),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التحليل الطبي الذكي',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'AI Health Insight',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Risk Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: riskColor.withOpacity(0.25)),
                          ),
                          child: Text(
                            riskText,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: const Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    // Summary
                    Text(
                      insight.summary,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: const Color(0xFF334155),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (insight.suggestions.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'توصيات الذكاء الاصطناعي:',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...insight.suggestions.map((suggestion) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 6.h, left: 8.w),
                                  child: Container(
                                    width: 7.r,
                                    height: 7.r,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF08C75A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    suggestion,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        if (state is HealthInsightError) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded, size: 40.sp, color: AppColors.error),
                SizedBox(height: 8.h),
                Text(
                  'تعذر تحميل تقرير الذكاء الاصطناعي',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => context.read<HealthInsightCubit>().fetchHealthInsight(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 150.h,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return const Color(0xFFFF4757);
      case 'Moderate':
        return const Color(0xFFFF9F43);
      case 'Low':
      default:
        return const Color(0xFF10B981);
    }
  }

  String _translateRiskLevel(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return 'مستوى مخاطر: مرتفع';
      case 'Moderate':
        return 'مستوى مخاطر: متوسط';
      case 'Low':
      default:
        return 'مستوى مخاطر: منخفض';
    }
  }
}
