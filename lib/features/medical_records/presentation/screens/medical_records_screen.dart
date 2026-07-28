import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/medical_records/domain/entities/medical_record_entity.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_cubit.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_state.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MedicalRecordCubit>()..fetchMedicalRecords(),
      child: const _MedicalRecordsView(),
    );
  }
}

class _MedicalRecordsView extends StatefulWidget {
  const _MedicalRecordsView();

  @override
  State<_MedicalRecordsView> createState() => _MedicalRecordsViewState();
}

class _MedicalRecordsViewState extends State<_MedicalRecordsView> {
  String? _typeFilter;

  static const _types = {'LabResult': 'نتيجة تحليل', 'Report': 'تقرير طبي', 'Scan': 'أشعة'};

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null || !context.mounted) return;

    final selectedType = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _types.entries
              .map((e) => ListTile(
                    title: Text(e.value, style: GoogleFonts.cairo()),
                    onTap: () => Navigator.of(sheetContext).pop(e.key),
                  ))
              .toList(),
        ),
      ),
    );

    if (selectedType == null || !context.mounted) return;

    context.read<MedicalRecordCubit>().uploadAndCreateRecord(
          file: File(image.path),
          type: selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('السجلات الطبية', style: GoogleFonts.cairo(color: const Color(0xFF1E2D4A), fontWeight: FontWeight.w900, fontSize: 18.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E2D4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _pickAndUpload(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<MedicalRecordCubit, MedicalRecordState>(
        listener: (context, state) {
          if (state is MedicalRecordSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم رفع السجل بنجاح', style: GoogleFonts.cairo()), backgroundColor: AppColors.success),
            );
            context.read<MedicalRecordCubit>().fetchMedicalRecords(type: _typeFilter);
          } else if (state is MedicalRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: GoogleFonts.cairo()), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildTypeFilterTabs(context),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeFilterTabs(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        children: [
          _filterChip(context, null, 'الكل'),
          ..._types.entries.map((e) => _filterChip(context, e.key, e.value)),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String? type, String label) {
    final selected = _typeFilter == type;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: GestureDetector(
        onTap: () {
          setState(() => _typeFilter = type);
          context.read<MedicalRecordCubit>().fetchMedicalRecords(type: type);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: selected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold, color: selected ? Colors.white : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MedicalRecordState state) {
    if (state is MedicalRecordLoading || state is MedicalRecordSubmitting) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is MedicalRecordError) {
      return Center(child: Text('حدث خطأ أثناء التحميل', style: GoogleFonts.cairo(color: Colors.grey)));
    }

    if (state is MedicalRecordLoaded) {
      if (state.records.isEmpty) {
        return Center(child: Text('لا توجد سجلات طبية', style: GoogleFonts.cairo(fontSize: 15.sp, color: Colors.grey)));
      }
      return RefreshIndicator(
        onRefresh: () => context.read<MedicalRecordCubit>().fetchMedicalRecords(type: _typeFilter),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          itemCount: state.records.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) => _recordCard(context, state.records[index]),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _recordCard(BuildContext context, MedicalRecordEntity record) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<MedicalRecordCubit>().deleteRecord(record.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.w),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => showDialog(
          context: context,
          builder: (_) => Dialog(
            child: InteractiveViewer(child: Image.network(record.fileUrl)),
          ),
        ),
        child: Container(
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
                child: Icon(_iconForType(record.type), color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title?.isNotEmpty == true ? record.title! : (_types[record.type] ?? record.type),
                      style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E2D4A)),
                    ),
                    if (record.recordDate != null)
                      Text(
                        '${record.recordDate!.year}-${record.recordDate!.month.toString().padLeft(2, '0')}-${record.recordDate!.day.toString().padLeft(2, '0')}',
                        style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B)),
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'LabResult':
        return Icons.biotech_rounded;
      case 'Scan':
        return Icons.medical_information_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}
