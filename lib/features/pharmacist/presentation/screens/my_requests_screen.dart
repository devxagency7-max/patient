import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_cubit.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_state.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:pharmacare/features/ratings/presentation/widgets/rating_bottom_sheet.dart';

/// Index of the chat tab inside MainShellScreen's IndexedStack (see
/// main_shell_screen.dart's `pages` list: Home, Reminders, Order, Chat,
/// Profile).
const _chatTabIndex = 3;

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyRequestsCubit>()..fetchMyRequests(),
      child: const _MyRequestsView(),
    );
  }
}

class _MyRequestsView extends StatelessWidget {
  const _MyRequestsView();

  (Color, String) _statusInfo(String status) {
    switch (status) {
      case 'Active':
        return (AppColors.success, 'صيدليك الحالي');
      case 'Rejected':
        return (AppColors.error, 'مرفوض');
      case 'Terminated':
        return (Colors.grey, 'منتهي');
      default:
        return (AppColors.warning, 'قيد الانتظار');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('حاله طلبك', style: GoogleFonts.cairo(color: const Color(0xFF1E2D4A), fontWeight: FontWeight.w900, fontSize: 18.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<MyRequestsCubit, MyRequestsState>(
        listener: (context, state) {
          if (state is MyRequestsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: GoogleFonts.cairo()), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is MyRequestsLoading || state is MyRequestsInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is MyRequestsLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Text(
                    'ليس لديك صيدلي بعد — اطلب صيدلي رعاية للحصول على متابعة شخصية.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<MyRequestsCubit>().fetchMyRequests(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.r),
                itemCount: state.requests.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => _requestCard(context, state.requests[index]),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _requestCard(BuildContext context, AssignmentRequestEntity request) {
    final (color, label) = _statusInfo(request.status);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.pharmacistName,
                  style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Text(label, style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          if (request.status == 'Rejected' && request.rejectionReason != null) ...[
            SizedBox(height: 6.h),
            Text('السبب: ${request.rejectionReason}', style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B))),
          ],
          if (request.status == 'Pending') ...[
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.read<MyRequestsCubit>().cancelRequest(request.assignmentId),
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                label: Text('إلغاء الطلب', style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ),
          ],
          if (request.status == 'Active') ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: [
                TextButton.icon(
                  onPressed: () => showRatingBottomSheet(
                    context,
                    targetType: 'Pharmacist',
                    pharmacistId: request.pharmacistId,
                    targetName: request.pharmacistName,
                  ),
                  icon: const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                  label: Text('قيّم الصيدلي', style: GoogleFonts.cairo(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ),
                TextButton.icon(
                  onPressed: () {
                    // ChatScreen already lives permanently inside
                    // MainShellScreen's IndexedStack (bottom-nav chat tab).
                    // Pushing another ChatScreen route here would spin up a
                    // second ChatCubit subscribed to the same singleton
                    // ChatSignalRService, duplicating every incoming
                    // message. The patient has at most one active
                    // pharmacist relationship, so returning to the shell
                    // and switching to the chat tab reaches the same
                    // conversation without creating a second instance.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    getIt<NavigationCubit>().setIndex(_chatTabIndex);
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryGreen, size: 18),
                  label: Text('تواصل مع الصيدلي', style: GoogleFonts.cairo(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ),
                TextButton.icon(
                  onPressed: () => _confirmTerminate(context, request),
                  icon: const Icon(Icons.link_off_rounded, color: AppColors.error, size: 18),
                  label: Text('إنهاء العلاقة', style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmTerminate(BuildContext context, AssignmentRequestEntity request) {
    final cubit = context.read<MyRequestsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إنهاء العلاقة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من إنهاء العلاقة مع ${request.pharmacistName}؟ لن تتمكن من التواصل معه بعد ذلك.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('رجوع', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.terminateRelationship(request.assignmentId);
            },
            child: Text('إنهاء', style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
