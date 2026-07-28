import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/home/presentation/widgets/home_header_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/upcoming_meds_widget.dart';
import 'package:pharmacare/features/home/presentation/widgets/health_record_card.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_cubit.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_cubit.dart';
import 'package:pharmacare/features/home/presentation/widgets/care_pharmacist_banner_widget.dart';

// الـ cubits دي بتتاخد من MainShellScreen (اتعملها provide مرة واحدة هناك)
// عشان build() هنا ميعملش re-fetch لكل الشاشة كل مرة الشجرة فوق تتبني تاني.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Stack(
        children: [
          _buildBackgroundMesh(),
          Builder(
            builder: (context) {
              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<HealthCubit>().fetchHistory(),
                    context.read<NotificationCubit>().fetchUnreadCount(),
                    context.read<RemindersCubit>().fetchRemindersAndPlans(),
                    context.read<MedicalRecordCubit>().fetchMedicalRecords(),
                    context.read<MyRequestsCubit>().fetchMyRequests(),
                  ]);
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    const HomeHeaderWidget(),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    const SliverToBoxAdapter(child: QuickActionsWidget()),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    const SliverToBoxAdapter(child: CarePharmacistBannerWidget()),
                    const SliverToBoxAdapter(child: UpcomingMedsWidget()),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    const SliverToBoxAdapter(child: HealthRecordCard()),
                    SliverToBoxAdapter(child: SizedBox(height: 110.h)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMesh() {
    return Stack(
      children: [
        Positioned(
          top: -80.h,
          right: -60.w,
          child: _buildGradientBlob(
            color: const Color(0xFF5A97DF).withOpacity(0.14),
            size: 420.r,
          ),
        ),
        Positioned(
          top: 300.h,
          left: -80.w,
          child: _buildGradientBlob(
            color: const Color(0xFF08C75A).withOpacity(0.07),
            size: 380.r,
          ),
        ),
        Positioned(
          bottom: -40.h,
          right: -40.w,
          child: _buildGradientBlob(
            color: AppColors.primary.withOpacity(0.09),
            size: 360.r,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 40,
          )
        ],
      ),
    );
  }
}

