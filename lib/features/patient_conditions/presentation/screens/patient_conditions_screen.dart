import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_cubit.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_state.dart';

class PatientConditionsScreen extends StatelessWidget {
  const PatientConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PatientConditionCubit>()..fetchConditions(),
      child: const _PatientConditionsView(),
    );
  }
}

class _PatientConditionsView extends StatelessWidget {
  const _PatientConditionsView();

  void _showAddSheet(BuildContext context) {
    final cubit = context.read<PatientConditionCubit>();
    final nameController = TextEditingController();
    String type = 'ChronicDisease';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة حالة صحية',
                      style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E2D4A)),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _typeChip(
                            label: 'مرض مزمن',
                            selected: type == 'ChronicDisease',
                            onTap: () => setSheetState(() => type = 'ChronicDisease'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _typeChip(
                            label: 'حساسية',
                            selected: type == 'Allergy',
                            onTap: () => setSheetState(() => type = 'Allergy'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.cairo(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'الاسم (مثال: السكري النوع الثاني)',
                        hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;
                          cubit.addCondition(
                            type: type,
                            name: nameController.text.trim(),
                          );
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _typeChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : const Color(0xFF64748B),
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
          'الحالات الصحية',
          style: GoogleFonts.cairo(color: const Color(0xFF1E2D4A), fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<PatientConditionCubit, PatientConditionState>(
        builder: (context, state) {
          if (state is PatientConditionLoading || state is PatientConditionInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is PatientConditionError) {
            return Center(
              child: Text('حدث خطأ: ${state.message}', style: GoogleFonts.cairo()),
            );
          }

          if (state is PatientConditionLoaded) {
            final allergies = state.conditions.where((c) => c.type == 'Allergy').toList();
            final chronic = state.conditions.where((c) => c.type == 'ChronicDisease').toList();

            if (state.conditions.isEmpty) {
              return Center(
                child: Text('لا توجد حالات صحية مسجلة', style: GoogleFonts.cairo(fontSize: 15.sp, color: Colors.grey)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PatientConditionCubit>().fetchConditions(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.r),
                children: [
                  if (allergies.isNotEmpty) ...[
                    _sectionHeader('الحساسية', AppColors.error, Icons.warning_amber_rounded),
                    ...allergies.map((c) => _conditionCard(context, c, accent: AppColors.error)),
                    SizedBox(height: 16.h),
                  ],
                  if (chronic.isNotEmpty) ...[
                    _sectionHeader('أمراض مزمنة', AppColors.primary, Icons.local_hospital_rounded),
                    ...chronic.map((c) => _conditionCard(context, c, accent: AppColors.primary)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Text(title, style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A))),
        ],
      ),
    );
  }

  Widget _conditionCard(BuildContext context, PatientConditionEntity condition, {required Color accent}) {
    return Dismissible(
      key: Key(condition.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<PatientConditionCubit>().deleteCondition(condition.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border(left: BorderSide(color: accent, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(condition.name, style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A))),
            if (condition.description != null && condition.description!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(condition.description!, style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B))),
            ],
          ],
        ),
      ),
    );
  }
}
