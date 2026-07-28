import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/pharmacist_cubit.dart';
import 'package:pharmacare/features/ratings/presentation/widgets/ratings_list_bottom_sheet.dart';

class PharmacistDetailScreen extends StatelessWidget {
  final PharmacistEntity pharmacist;

  const PharmacistDetailScreen({super.key, required this.pharmacist});

  void _showRequestModal(BuildContext context) {
    final cubit = context.read<PharmacistCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      'طلب رعاية طبية خاصة',
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2D4A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'مع الصيدلي: د. ${pharmacist.name}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'سيقوم الصيدلي بمتابعة خطتك العلاجية، الجرعات اليومية، والرد على استفساراتك وتنبيهات الحساسية والتفاعلات الدوائية.',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () {
                          cubit.requestPharmacist(pharmacistId: pharmacist.id);
                          Navigator.of(bottomSheetContext).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'تأكيد إبرام عقد الرعاية الطبية ✦',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        pharmacist.imageUrl != null && pharmacist.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'الملف الشخصي للصيدلي',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: pharmacist.isAvailable
                ? () => _showRequestModal(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: pharmacist.isAvailable
                  ? AppColors.primary
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              pharmacist.isAvailable
                  ? 'طلب متابعة رعاية مع د. ${pharmacist.name}'
                  : 'غير متاح للقبول حالياً',
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Default Doctor Fallback
                  Stack(
                    children: [
                      Container(
                        width: 90.r,
                        height: 90.r,
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: pharmacist.isAvailable
                                ? [
                                    const Color(0xFF5A97DF),
                                    const Color(0xFF08C75A),
                                  ]
                                : [Colors.grey.shade300, Colors.grey.shade400],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 42.r,
                          backgroundColor: const Color(0xFFEEF5FC),
                          backgroundImage: hasImage
                              ? NetworkImage(pharmacist.imageUrl!)
                              : null,
                          child: !hasImage
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
                                      size: 44.sp,
                                      color: const Color(0xFF2F6BFF),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 4.r,
                        right: 4.r,
                        child: Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: BoxDecoration(
                            color: pharmacist.isAvailable
                                ? const Color(0xFF08C75A)
                                : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'د. ${pharmacist.name}',
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pharmacist.specialization != null &&
                            pharmacist.specialization!.isNotEmpty
                        ? pharmacist.specialization!
                        : 'صيدلي ',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Rating Button
                  GestureDetector(
                    onTap: () => showRatingsListBottomSheet(
                      context,
                      targetType: 'Pharmacist',
                      pharmacistId: pharmacist.id,
                      targetName: pharmacist.name,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFFBE21),
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            pharmacist.averageRating > 0
                                ? pharmacist.averageRating.toStringAsFixed(1)
                                : 'جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '(عرض جميع التقييمات والآراء)',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _statBox(
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF2F6BFF),
                    value: pharmacist.maxPatientsLimit != null
                        ? '${pharmacist.activePatientsCount} / ${pharmacist.maxPatientsLimit}'
                        : '${pharmacist.activePatientsCount}',
                    label: 'المرضى المتابعين',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _statBox(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFF08C75A),
                    value: 'معتمد',
                    label: 'نقابة الصيادلة',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Bio / Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عن الصيدلي والرعاية الطبية',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'متخصص في متابعة خطط العلاج للأمراض المزمنة، ضبط مواعيد الجرعات، وتجنب التداخلات الدوائية الضارة. يوفر استشارات ورعاية صحية شخصية مستمرة للمريض.',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5.sp,
                      height: 1.6,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Services Features List
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خدمات المتابعة المتاحة',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _serviceTile('متابعة خطة الأدوية والجرعات اليومية'),
                  _serviceTile('تنبيهات الحساسية والتفاعلات الدوائية'),
                  _serviceTile('استشارات مباشرة وإرشادات السلامة'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTile(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF08C75A),
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
