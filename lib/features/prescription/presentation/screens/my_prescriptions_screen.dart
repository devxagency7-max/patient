import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/my_prescriptions_cubit.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/my_prescriptions_state.dart';

class MyPrescriptionsScreen extends StatelessWidget {
  const MyPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyPrescriptionsCubit>()..fetchMyPrescriptions(),
      child: const _MyPrescriptionsView(),
    );
  }
}

class _MyPrescriptionsView extends StatelessWidget {
  const _MyPrescriptionsView();

  static const _statusLabels = {
    'Pending': 'قيد المراجعة',
    'Approved': 'تمت الموافقة',
    'Rejected': 'مرفوضة',
    'Valid': 'سارية',
    'Used': 'مستخدمة',
    'Expired': 'منتهية',
    'Cancelled': 'ملغاة',
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Valid':
        return AppColors.success;
      case 'Rejected':
      case 'Expired':
      case 'Cancelled':
        return AppColors.error;
      default:
        return const Color(0xFFFF9F43);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'روشتاتي',
          style: GoogleFonts.cairo(color: const Color(0xFF1E2D4A), fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
      ),
      body: BlocBuilder<MyPrescriptionsCubit, MyPrescriptionsState>(
        builder: (context, state) {
          if (state is MyPrescriptionsLoading || state is MyPrescriptionsInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is MyPrescriptionsError) {
            return Center(child: Text('حدث خطأ أثناء التحميل', style: GoogleFonts.cairo(color: Colors.grey)));
          }

          final prescriptions = (state as MyPrescriptionsLoaded).prescriptions;

          if (prescriptions.isEmpty) {
            return Center(child: Text('لا توجد روشتات مرفوعة', style: GoogleFonts.cairo(fontSize: 15.sp, color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MyPrescriptionsCubit>().fetchMyPrescriptions(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              itemCount: prescriptions.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) => _prescriptionCard(context, prescriptions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _prescriptionCard(BuildContext context, PrescriptionEntity prescription) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prescription.doctorName?.isNotEmpty == true ? prescription.doctorName! : 'روشتة طبية',
                  style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
                ),
                if (prescription.clinicName?.isNotEmpty == true)
                  Text(
                    prescription.clinicName!,
                    style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _statusColor(prescription.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _statusLabels[prescription.status] ?? prescription.status,
              style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.bold, color: _statusColor(prescription.status)),
            ),
          ),
        ],
      ),
    );
  }
}
