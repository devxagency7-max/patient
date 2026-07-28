import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_cubit.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_state.dart';

Future<void> showRatingBottomSheet(
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
      create: (_) => getIt<RatingCubit>(),
      child: _RatingBottomSheetContent(
        targetType: targetType,
        pharmacistId: pharmacistId,
        pharmacyId: pharmacyId,
        targetName: targetName,
      ),
    ),
  );
}

class _RatingBottomSheetContent extends StatefulWidget {
  final String targetType;
  final String? pharmacistId;
  final String? pharmacyId;
  final String targetName;

  const _RatingBottomSheetContent({
    required this.targetType,
    this.pharmacistId,
    this.pharmacyId,
    required this.targetName,
  });

  @override
  State<_RatingBottomSheetContent> createState() => _RatingBottomSheetContentState();
}

class _RatingBottomSheetContentState extends State<_RatingBottomSheetContent> {
  int _score = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingCubit, RatingState>(
      listener: (context, state) {
        if (state is RatingSubmitSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('شكراً لتقييمك!', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is RatingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is RatingSubmitting;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(height: 24.h),
                    Text(
                      widget.targetType == 'Pharmacist' ? 'تقييم الصيدلي' : 'تقييم الصيدلية',
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2D4A),
                      ),
                    ),
                    Text(
                      widget.targetName,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return IconButton(
                            onPressed: () => setState(() => _score = starValue),
                            icon: Icon(
                              starValue <= _score ? Icons.star_rounded : Icons.star_border_rounded,
                              color: const Color(0xFFFFBE21),
                              size: 34.sp,
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'تعليق إضافي (اختياري):',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                        ],
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        maxLength: 1000,
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'اكتب رأيك هنا...',
                          hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                context.read<RatingCubit>().submitRating(
                                      targetType: widget.targetType,
                                      pharmacistId: widget.pharmacistId,
                                      pharmacyId: widget.pharmacyId,
                                      score: _score,
                                      comment: _commentController.text.trim().isNotEmpty
                                          ? _commentController.text.trim()
                                          : null,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'إرسال التقييم',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
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
        );
      },
    );
  }
}
