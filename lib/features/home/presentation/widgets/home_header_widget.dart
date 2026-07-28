import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_state.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_state.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_state.dart';
import 'package:pharmacare/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:pharmacare/features/health_readings/presentation/screens/add_health_reading_screen.dart';
import 'package:pharmacare/features/health_readings/presentation/screens/reading_input_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 255.h,
      toolbarHeight: 68.h,
      backgroundColor: const Color(0xFFF4F7FC).withOpacity(0.92),
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18.r)),
      ),
      titleSpacing: 20.w,
      automaticallyImplyLeading: false,
      title: _buildTopRow(context),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 68.h, 20.w, 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildGreetingRow(),
                SizedBox(height: 14.h),
                _buildHealthStatsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo_icon_app-removebg-preview.png',
              width: 38.r,
              height: 38.r,
            ),
            SizedBox(width: 10.w),
            Text(
              'طمنّي',
              style: GoogleFonts.cairo(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            // NotificationsScreen provides its own NotificationCubit instance
            // (registerFactory, not a singleton) and marks everything read
            // there — this header's badge is a separate instance and won't
            // see that update on its own, so refresh it explicitly on return.
            final notificationCubit = context.read<NotificationCubit>();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            notificationCubit.fetchUnreadCount();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_none_rounded, color: const Color(0xFF334155), size: 24.r),
              ),
              Positioned(
                top: -3.r,
                right: -3.r,
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    final unread = state is NotificationLoaded ? state.unreadCount : 0;
                    if (unread <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      constraints: BoxConstraints(minWidth: 20.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4757),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingRow() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final fbUser = FirebaseAuth.instance.currentUser;

        String name = 'مستخدم';
        if (user != null && user.name.isNotEmpty) {
          name = user.name;
        } else if (fbUser?.displayName != null && fbUser!.displayName!.isNotEmpty) {
          name = fbUser.displayName!;
        }

        String? photoUrl;
        if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
          photoUrl = user.avatarUrl;
        } else if (fbUser?.photoURL != null && fbUser!.photoURL!.isNotEmpty) {
          photoUrl = fbUser.photoURL;
        }

        return Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              padding: EdgeInsets.all(2.5.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A97DF), Color(0xFF08C75A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A97DF).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Icon(Icons.person_rounded, color: const Color(0xFF5A97DF), size: 28.r),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person_rounded, color: const Color(0xFF5A97DF), size: 28.r),
                        )
                      : Icon(Icons.person_rounded, color: const Color(0xFF5A97DF), size: 28.r),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'أهلاً بك، $name',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text('👋', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'نتمنى لك يوم صحي وحياة أفضل',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static const _bloodPressureInfo = ReadingTypeInfo(
    type: ReadingType.bloodPressure,
    titleAr: 'ضغط الدم',
    titleEn: 'Blood Pressure',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFF4757),
  );

  static const _sugarInfo = ReadingTypeInfo(
    type: ReadingType.bloodSugar,
    titleAr: 'السكر',
    titleEn: 'Blood Sugar',
    icon: Icons.show_chart_rounded,
    color: Color(0xFFFF9F43),
  );

  static const _weightInfo = ReadingTypeInfo(
    type: ReadingType.weight,
    titleAr: 'الوزن',
    titleEn: 'Weight',
    icon: Icons.monitor_weight_outlined,
    color: Color(0xFF00B894),
  );

  void _navigateToReading(BuildContext context, ReadingTypeInfo info) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingInputScreen(readingInfo: info),
      ),
    );
  }

  Widget _buildHealthStatsRow() {
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (context, state) {
        String bp = '---', sugar = '---', weight = '---';
        if (state is HealthSuccess && state.history != null) {
          for (var item in state.history!) {
            if (item.type == 'BloodPressure') bp = item.latestValue.toInt().toString();
            if (item.type == 'Sugar') sugar = item.latestValue.toInt().toString();
            if (item.type == 'Weight') weight = item.latestValue.toInt().toString();
          }
        }
        return Row(
          children: [
            _statCard(
              value: bp,
              label: 'ضغط الدم',
              unit: 'mmHg',
              accentColor: const Color(0xFFFF4757),
              onTap: () => _navigateToReading(context, _bloodPressureInfo),
            ),
            SizedBox(width: 10.w),
            _statCard(
              value: sugar,
              label: 'السكر',
              unit: 'mg/dL',
              accentColor: const Color(0xFFFF9F43),
              onTap: () => _navigateToReading(context, _sugarInfo),
            ),
            SizedBox(width: 10.w),
            _statCard(
              value: weight,
              label: 'الوزن',
              unit: 'kg',
              accentColor: const Color(0xFF08C75A),
              onTap: () => _navigateToReading(context, _weightInfo),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required String unit,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final bool hasValue = value != '---' && value.trim().isNotEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasValue ? const Color(0xFFE2E8F0) : accentColor.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              if (hasValue) ...[
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ] else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: accentColor, size: 14.r),
                      SizedBox(width: 2.w),
                      Text(
                        'إضافة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

