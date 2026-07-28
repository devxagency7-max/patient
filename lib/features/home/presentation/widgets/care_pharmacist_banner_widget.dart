import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_cubit.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_state.dart';
import 'package:pharmacare/features/pharmacist/presentation/screens/pharmacist_directory_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CarePharmacistBannerWidget extends StatefulWidget {
  const CarePharmacistBannerWidget({super.key});

  @override
  State<CarePharmacistBannerWidget> createState() =>
      _CarePharmacistBannerWidgetState();
}

class _CarePharmacistBannerWidgetState
    extends State<CarePharmacistBannerWidget> {
  late bool _hasActiveOrPending = context
      .read<MyRequestsCubit>()
      .cachedHasActiveOrPending;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyRequestsCubit, MyRequestsState>(
      listener: (context, state) {
        if (state is MyRequestsLoaded) {
          setState(() {
            _hasActiveOrPending = state.requests.any(
              (r) => r.status == 'Active' || r.status == 'Pending',
            );
          });
        }
      },
      child: Builder(
        builder: (context) {
          if (_hasActiveOrPending) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A8A), // Deep Royal Blue
                  Color(0xFF2F6BFF), // Vibrant Care Blue
                  Color(0xFF0F766E), // Emerald Teal accent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F6BFF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Stack(
                children: [
                  Positioned(
                    top: -30.r,
                    left: -30.r,
                    child: Container(
                      width: 140.r,
                      height: 140.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF08C75A).withOpacity(0.25),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40.r,
                    right: -20.r,
                    child: Container(
                      width: 150.r,
                      height: 150.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50.r,
                              height: 50.r,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.medical_services_rounded,
                                color: const Color(0xFF2F6BFF),
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF08C75A,
                                      ).withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF08C75A,
                                        ).withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6.r,
                                          height: 6.r,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF08C75A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'خدمة الرعاية الشخصية ✦',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF6EE7B7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'احصل على صيدلي متابع لك 🩺',
                                    style: GoogleFonts.cairo(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'تواصل مباشرة مع صيدلي معتمد لمتابعة خطتك العلاجية، مواعيد جرعاتك، وتنبيهات الحساسية والتداخلات الدوائية بشكل شخصي ومستمر.',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5.sp,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PharmacistDirectoryScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'طلب صيدلي رعاية الآن',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18.sp,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
