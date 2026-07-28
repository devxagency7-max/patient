import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_state.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/order_tracking_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderCubit>()..fetchMyOrders(),
      child: const MyOrdersView(),
    );
  }
}

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['', 'Pending', 'Accepted', 'Completed', 'Cancelled'];
  final List<String> _tabLabels = ['الكل', 'قيد المراجعة', 'مقبول', 'مكتمل', 'ملغي'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final selectedStatus = _statuses[_tabController.index];
        context.read<OrderCubit>().fetchMyOrders(status: selectedStatus.isNotEmpty ? selectedStatus : null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Text(
          'طلباتي ومتابعة الحالة',
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.sp),
          unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13.sp),
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Stack(
        children: [
          _buildMeshBackground(),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (state is OrderError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 60.sp, color: AppColors.error),
                        SizedBox(height: 16.h),
                        Text(
                          'تعذر تحميل الطلبات',
                          style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(state.message, style: GoogleFonts.cairo(color: Colors.grey)),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            final status = _statuses[_tabController.index];
                            context.read<OrderCubit>().fetchMyOrders(status: status.isNotEmpty ? status : null);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is MyOrdersLoaded) {
                final orders = state.orders;
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80.sp, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد طلبات في هذه القائمة',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    final status = _statuses[_tabController.index];
                    await context.read<OrderCubit>().fetchMyOrders(status: status.isNotEmpty ? status : null);
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16.r),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: index * 50),
                        child: _buildOrderCard(context, order),
                      );
                    },
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80.h,
          right: -50.w,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 100.h,
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
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final statusColor = _getStatusColor(order.orderStatus);
    final statusText = _translateStatus(order.orderStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: order.id),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'طلب #${order.id.substring(0, order.id.length < 8 ? order.id.length : 8).toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E2D4A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: Colors.grey.withOpacity(0.15), height: 1),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.store_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        order.pharmacyName,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2D4A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Text(
                      _formatDateTime(order.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.finalPrice != null
                          ? '${order.finalPrice!.toStringAsFixed(2)} ج.م'
                          : 'بانتظار تحديد السعر',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: order.finalPrice != null ? AppColors.primary : Colors.orange,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'تتبع التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد المراجعة';
      case 'Accepted':
        return 'مقبول وفي التجهيز';
      case 'Completed':
        return 'مكتمل ومستلم';
      case 'Rejected':
        return 'مرفوض';
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
}
