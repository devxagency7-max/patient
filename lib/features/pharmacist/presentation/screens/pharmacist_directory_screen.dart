import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/pharmacist_cubit.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/pharmacist_state.dart';
import 'package:pharmacare/features/pharmacist/presentation/screens/pharmacist_detail_screen.dart';
import 'package:pharmacare/features/ratings/presentation/widgets/ratings_list_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class PharmacistDirectoryScreen extends StatelessWidget {
  const PharmacistDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PharmacistCubit>()..fetchPharmacists(),
      child: const PharmacistDirectoryView(),
    );
  }
}

class PharmacistDirectoryView extends StatefulWidget {
  const PharmacistDirectoryView({super.key});

  @override
  State<PharmacistDirectoryView> createState() => _PharmacistDirectoryViewState();
}

class _PharmacistDirectoryViewState extends State<PharmacistDirectoryView> {
  void _showRequestModal(BuildContext context, PharmacistEntity pharmacist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<PharmacistCubit>(),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
                      'طلب رعاية طبية',
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2D4A),
                      ),
                    ),
                    Text(
                      'مع الصيدلي: ${pharmacist.name}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<PharmacistCubit>().requestPharmacist(
                                pharmacistId: pharmacist.id,
                              );
                          Navigator.of(bottomSheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          'تأكيد الطلب لإبرام العقد',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.white),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'دليل الصيادلة',
          style: GoogleFonts.cairo(
            color: const Color(0xFF1E2D4A),
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundBlob(),
          BlocConsumer<PharmacistCubit, PharmacistState>(
            listener: (context, state) {
              if (state is PharmacistRequestSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال طلب الرعاية بنجاح وسيتواصل معك الصيدلي قريباً',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.read<PharmacistCubit>().fetchPharmacists();
              } else if (state is PharmacistError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PharmacistLoading) {
                return _buildShimmerList();
              }

              if (state is PharmacistsLoaded) {
                final pharmacists = state.pharmacists;
                if (pharmacists.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20.r),
                  itemCount: pharmacists.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final pharmacist = pharmacists[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildPharmacistCard(context, pharmacist),
                    );
                  },
                );
              }

              if (state is PharmacistError) {
                return _buildErrorState(context, state.message);
              }

              return _buildShimmerList();
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
          top: -50.h,
          right: -50.w,
          child: Container(
            width: 250.w,
            height: 250.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -100.h,
          left: -100.w,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.06),
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

  Widget _buildPharmacistCard(BuildContext context, PharmacistEntity pharmacist) {
    final double occupancyRatio = pharmacist.maxPatientsLimit != null && pharmacist.maxPatientsLimit! > 0
        ? (pharmacist.activePatientsCount / pharmacist.maxPatientsLimit!).clamp(0.0, 1.0)
        : 0.0;

    Color occupancyColor = AppColors.success;
    if (occupancyRatio >= 1.0 || !pharmacist.isAvailable) {
      occupancyColor = AppColors.error;
    } else if (occupancyRatio >= 0.75) {
      occupancyColor = AppColors.warning;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<PharmacistCubit>(),
              child: PharmacistDetailScreen(pharmacist: pharmacist),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2D4A).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (pharmacist.isAvailable ? AppColors.success : Colors.grey[300]!)
                              .withOpacity(0.5),
                          width: 2.5.r,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 34.r,
                        backgroundColor: const Color(0xFFEEF5FC),
                        backgroundImage: pharmacist.imageUrl != null && pharmacist.imageUrl!.isNotEmpty
                            ? NetworkImage(pharmacist.imageUrl!)
                            : null,
                        child: pharmacist.imageUrl == null || pharmacist.imageUrl!.isEmpty
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFE0EEFF),
                                    ),
                                  ),
                                  Icon(
                                    Icons.medical_services_rounded,
                                    size: 32.sp,
                                    color: const Color(0xFF2F6BFF),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  Positioned(
                    bottom: 2.h,
                    right: 2.w,
                    child: Container(
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: pharmacist.isAvailable ? AppColors.success : Colors.grey[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.r),
                        boxShadow: [
                          BoxShadow(
                            color: (pharmacist.isAvailable ? AppColors.success : Colors.grey)
                                .withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Content (Name, Specialization, Rating)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pharmacist.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2D4A),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.primary,
                          size: 16.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    if (pharmacist.specialization != null && pharmacist.specialization!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              pharmacist.specialization!,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 6.h),
                    // Clickable Rating Row
                    GestureDetector(
                      onTap: () => showRatingsListBottomSheet(
                        context,
                        targetType: 'Pharmacist',
                        pharmacistId: pharmacist.id,
                        targetName: pharmacist.name,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFFBE21),
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            pharmacist.averageRating > 0
                                ? pharmacist.averageRating.toStringAsFixed(1)
                                : 'جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2D4A),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '(عرض التقييمات)',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: Colors.grey[100], height: 1.h),
          ),

          // Occupancy & Limits Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 15.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'حجم الرعاية الحالية:',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    pharmacist.maxPatientsLimit != null
                        ? '${pharmacist.activePatientsCount} / ${pharmacist.maxPatientsLimit} مريض'
                        : '${pharmacist.activePatientsCount} مريض نشط',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: occupancyColor,
                    ),
                  ),
                ],
              ),
              if (pharmacist.maxPatientsLimit != null && pharmacist.maxPatientsLimit! > 0) ...[
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: occupancyRatio,
                    minHeight: 6.h,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 16.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: pharmacist.isAvailable 
                  ? () => _showRequestModal(context, pharmacist)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pharmacist.isAvailable ? Icons.add_task_rounded : Icons.lock_outline_rounded,
                    size: 16.sp,
                    color: pharmacist.isAvailable ? Colors.white : Colors.grey[500],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    pharmacist.isAvailable ? 'طلب عقد رعاية طبية' : 'مكتمل العدد حالياً',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: pharmacist.isAvailable ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 130.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد صيادلة متاحون حالياً',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ أثناء تحميل الصيادلة',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(message, style: GoogleFonts.cairo(color: Colors.grey)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<PharmacistCubit>().fetchPharmacists(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
