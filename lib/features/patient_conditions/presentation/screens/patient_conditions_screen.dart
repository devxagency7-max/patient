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

class _PatientConditionsView extends StatefulWidget {
  const _PatientConditionsView();

  @override
  State<_PatientConditionsView> createState() => _PatientConditionsViewState();
}

class _PatientConditionsViewState extends State<_PatientConditionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSheet(BuildContext context) {
    final conditionCubit = context.read<PatientConditionCubit>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String type = 'ChronicDisease';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'إضافة حالة صحية جديدة',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
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
                          hintText: type == 'Allergy'
                              ? 'اسم الحساسية (مثال: حساسية البنسلين)'
                              : 'اسم المرض (مثال: السكري / ارتفاع الضغط)',
                          hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'ملاحظات أو إرشادات الطبيب (اختياري)',
                          hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) return;
                            conditionCubit.addCondition(
                              type: type,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim().isNotEmpty
                                  ? descriptionController.text.trim()
                                  : null,
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'حفظ الحالة الصحية',
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
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
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
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'الأمراض المزمنة والحساسية',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF5FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary),
            ),
            onPressed: () => _showAddSheet(context),
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'أمراض مزمنة'),
                Tab(text: 'الحساسية والآثار'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<PatientConditionCubit, PatientConditionState>(
        builder: (context, state) {
          if (state is PatientConditionLoading || state is PatientConditionInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is PatientConditionError) {
            return Center(
              child: Text(
                'حدث خطأ: ${state.message}',
                style: GoogleFonts.cairo(color: AppColors.error),
              ),
            );
          }

          if (state is PatientConditionLoaded) {
            final chronic = state.conditions
                .where((c) => c.type == 'ChronicDisease')
                .toList();
            final allergies = state.conditions
                .where((c) => c.type == 'Allergy')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildConditionsList(context, chronic, isChronic: true),
                _buildConditionsList(context, allergies, isChronic: false),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildConditionsList(
    BuildContext context,
    List<PatientConditionEntity> list, {
    required bool isChronic,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isChronic ? Icons.local_hospital_outlined : Icons.warning_amber_rounded,
              size: 54.r,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              isChronic ? 'لا توجد أمراض مزمنة مسجلة' : 'لا توجد حالات حساسية مسجلة',
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton.icon(
              onPressed: () => _showAddSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                isChronic ? 'إضافة مرض مزمن' : 'إضافة حالة حساسية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PatientConditionCubit>().fetchConditions(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final condition = list[index];
          final accentColor = isChronic ? const Color(0xFF5A97DF) : const Color(0xFFFF4757);
          return _conditionCard(context, condition, accentColor: accentColor);
        },
      ),
    );
  }

  Widget _conditionCard(
    BuildContext context,
    PatientConditionEntity condition, {
    required Color accentColor,
  }) {
    return Dismissible(
      key: Key(condition.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<PatientConditionCubit>().deleteCondition(condition.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.w),
        margin: EdgeInsets.only(bottom: 4.h),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                condition.type == 'Allergy'
                    ? Icons.warning_amber_rounded
                    : Icons.favorite_rounded,
                color: accentColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.name,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (condition.description != null &&
                      condition.description!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      condition.description!,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
