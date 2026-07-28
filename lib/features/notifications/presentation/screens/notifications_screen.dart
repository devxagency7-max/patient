import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/notifications/domain/entities/notification_entity.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_state.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationCubit>()..openNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'الإشعارات',
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
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return _buildShimmerList();
          }

          if (state is NotificationError) {
            return _buildErrorState(context, state.message);
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().fetchNotifications(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.r),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => _notificationCard(context, state.notifications[index]),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _notificationCard(BuildContext context, NotificationEntity notification) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationCubit>().markAsRead(notification.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: notification.isRead
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notification.isRead)
              Container(
                margin: EdgeInsets.only(top: 6.h, left: 8.w),
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: const Color(0xFF1E2D4A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 70.h,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text('لا توجد إشعارات حالياً', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'تعذر تحميل الإشعارات حالياً',
              style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'برجاء المحاولة مرة أخرى لاحقاً',
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<NotificationCubit>().fetchNotifications(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
