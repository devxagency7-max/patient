import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/ratings/domain/entities/rating_entity.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_cubit.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_state.dart';

Future<void> showRatingsListBottomSheet(
  BuildContext context, {
  required String targetType,
  String? pharmacistId,
  String? pharmacyId,
  required String targetName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) {
        final cubit = getIt<RatingCubit>();
        if (targetType == 'Pharmacist' && pharmacistId != null) {
          cubit.fetchPharmacistRatings(pharmacistId: pharmacistId);
        } else if (pharmacyId != null) {
          cubit.fetchPharmacyRatings(pharmacyId: pharmacyId);
        }
        return cubit;
      },
      child: _RatingsListSheetContent(targetType: targetType, targetName: targetName),
    ),
  );
}

class _RatingsListSheetContent extends StatelessWidget {
  final String targetType;
  final String targetName;

  const _RatingsListSheetContent({required this.targetType, required this.targetName});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  targetType == 'Pharmacist' ? 'تقييمات الصيدلي' : 'تقييمات الصيدلية',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2D4A),
                  ),
                ),
                Text(
                  targetName,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<RatingCubit, RatingState>(
                    builder: (context, state) {
                      if (state is RatingListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is RatingListError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.grey),
                          ),
                        );
                      }
                      if (state is RatingListLoaded) {
                        if (state.ratings.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد تقييمات بعد',
                              style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAverageHeader(state),
                            SizedBox(height: 8.h),
                            Expanded(
                              child: ListView.separated(
                                controller: scrollController,
                                itemCount: state.ratings.length,
                                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                                itemBuilder: (context, index) =>
                                    _buildRatingCard(state.ratings[index]),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAverageHeader(RatingListLoaded state) {
    return Row(
      children: [
        Icon(Icons.star_rounded, color: const Color(0xFFFFBE21), size: 22.sp),
        SizedBox(width: 6.w),
        Text(
          state.averageScore.toStringAsFixed(1),
          style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 6.w),
        Text(
          '(${state.ratings.length} تقييم)',
          style: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRatingCard(RatingEntity rating) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rating.reviewerName,
                style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('yyyy/MM/dd').format(rating.createdAt),
                style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating.score ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFFFBE21),
                size: 16.sp,
              ),
            ),
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              rating.comment!,
              style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }
}
