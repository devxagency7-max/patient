import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_state.dart';
import 'package:pharmacare/features/ratings/presentation/widgets/rating_bottom_sheet.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderCubit>()..fetchOrderDetail(orderId),
      child: Scaffold(
        backgroundColor: AppColors.primaryLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            'تتبع الطلب',
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
            _buildMeshBackground(),
            BlocConsumer<OrderCubit, OrderState>(
              listener: (context, state) {
                if (state is OrderCancelledSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إلغاء الطلب بنجاح',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<OrderCubit>().fetchOrderDetail(orderId);
                } else if (state is OrderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state is OrderDetailLoaded) {
                  final order = state.order;
                  return _buildOrderDetails(context, order);
                }

                if (state is OrderError) {
                  return _buildErrorState(context, state.message);
                }

                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeshBackground() {
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
            width: 350.w,
            height: 350.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.06),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ],
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
            'حدث خطأ أثناء تحميل تفاصيل الطلب',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(message, style: GoogleFonts.cairo(color: Colors.grey)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<OrderCubit>().fetchOrderDetail(orderId),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    final canCancel = order.orderStatus == 'Pending' || order.orderStatus == 'Accepted';
    final canRate = order.orderStatus == 'Completed';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كارت رقم الطلب وحالته
          _buildInfoCard(order),
          SizedBox(height: 20.h),
          // تايم لاين الحالات
          _buildTimelineCard(order.statusHistory),
          SizedBox(height: 20.h),
          // كارت المنتجات
          _buildItemsCard(order.items),
          SizedBox(height: 20.h),
          if (canRate)
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showRatingBottomSheet(
                    context,
                    targetType: 'Pharmacy',
                    pharmacyId: order.pharmacyId,
                    targetName: order.pharmacyName,
                  ),
                  icon: const Icon(Icons.star_rounded, color: Colors.white),
                  label: Text(
                    'قيّم الصيدلية',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ),
          SizedBox(height: 12.h),
          // زر الإلغاء
          if (canCancel)
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancelOrder(context),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: Text(
                    'إلغاء الطلب',
                    style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(OrderEntity order) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('رقم الطلب', '#${order.id.substring(0, 8).toUpperCase()}', isBold: true),
          const Divider(),
          _infoRow('الصيدلية', order.pharmacyName),
          const Divider(),
          _infoRow('تاريخ الطلب', _formatDateTime(order.createdAt)),
          const Divider(),
          _infoRow(
            'حالة الطلب',
            _translateStatus(order.orderStatus),
            color: _getStatusColor(order.orderStatus),
            isBold: true,
          ),
          const Divider(),
          _infoRow(
            'السعر النهائي',
            order.finalPrice != null ? '${order.finalPrice!.toStringAsFixed(2)} ج.م' : 'يحدد لاحقاً بانتظار تسعير الصيدلية',
            color: order.finalPrice != null ? AppColors.primary : Colors.grey,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(List<OrderStatusHistoryEntity> history) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خطوات التتبع',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2D4A),
            ),
          ),
          SizedBox(height: 20.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final step = history[index];
              final isLast = index == history.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLast ? AppColors.primary : const Color(0xFFCBD5E1),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      if (index != history.length - 1)
                        Container(
                          width: 2.w,
                          height: 50.h,
                          color: const Color(0xFFE2E8F0),
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _translateStatus(step.status),
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isLast ? const Color(0xFF1E2D4A) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          step.comments,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _formatDateTime(step.changedAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<OrderItemEntity> items) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'منتجات الطلب',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2D4A),
            ),
          ),
          SizedBox(height: 12.h),
          const Divider(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F6BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(Icons.medication_rounded, color: AppColors.primary),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          Text(
                            'الجرعة: ${item.dosage}',
                            style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'العدد: ${item.quantity}',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color color = const Color(0xFF1E2D4A), bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF64748B)),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد المراجعة';
      case 'Accepted':
        return 'مقبول وبانتظار التجهيز';
      case 'Completed':
        return 'تم التوصيل بنجاح';
      case 'Rejected':
        return 'تم رفض الطلب';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9F43);
      case 'Accepted':
        return AppColors.primary;
      case 'Completed':
        return AppColors.primaryGreen;
      case 'Rejected':
      case 'Cancelled':
        return const Color(0xFFFF4757);
      default:
        return Colors.black;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } catch (_) {
      return dateTimeStr;
    }
  }

  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'إلغاء الطلب',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'رجوع',
              style: GoogleFonts.cairo(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<OrderCubit>().cancelOrder(orderId);
            },
            child: Text(
              'تأكيد الإلغاء',
              style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
