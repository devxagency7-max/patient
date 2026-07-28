import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_state.dart';
import 'package:pharmacare/features/health_readings/presentation/screens/add_health_reading_screen.dart';

/// صفحة إدخال قراءة صحية - Reading Input Screen بنمط زجاجي
class ReadingInputScreen extends StatefulWidget {
  final ReadingTypeInfo readingInfo;

  const ReadingInputScreen({super.key, required this.readingInfo});

  @override
  State<ReadingInputScreen> createState() => _ReadingInputScreenState();
}

class _ReadingInputScreenState extends State<ReadingInputScreen> {
  // Controllers لكل الحقول
  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '80');
  final _sugarController = TextEditingController(text: '95');
  final _weightController = TextEditingController(text: '75');
  final _tempController = TextEditingController(text: '37');
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _formattedDate {
    return DateFormat('dd MMMM yyyy, hh:mm a', 'ar').format(_selectedDate);
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F6BFF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveReading(BuildContext context) {
    double value = 0;
    String type = '';

    switch (widget.readingInfo.type) {
      case ReadingType.bloodPressure:
        type = 'BloodPressure';
        value = double.tryParse(_systolicController.text) ?? 0;
        break;
      case ReadingType.bloodSugar:
        type = 'Sugar';
        value = double.tryParse(_sugarController.text) ?? 0;
        break;
      case ReadingType.weight:
        type = 'Weight';
        value = double.tryParse(_weightController.text) ?? 0;
        break;
      case ReadingType.temperature:
        return;
    }

    if (value <= 0) {
      _showErrorSnackBar('يرجى إدخال قيمة صحيحة');
      return;
    }

    context.read<HealthCubit>().addReading(
      type: type,
      value: value,
      recordedAt: DateTime.now(),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFFFF4757),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _sugarController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<HealthCubit>(),
      child: BlocConsumer<HealthCubit, HealthState>(
        listener: (context, state) {
          if (state is HealthSuccess && state.newReading != null) {
            context.read<HealthCubit>().fetchHistory();
            Navigator.of(context).pop();
          } else if (state is HealthError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF0F5FF),
            body: Stack(
              children: [
                _buildMeshBackground(),
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 600),
                              child: _buildInfoCard(),
                            ),
                            SizedBox(height: 24.h),
                            ..._buildFieldsForType(),
                            SizedBox(height: 24.h),
                            _buildDateTimeField(),
                            SizedBox(height: 40.h),
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              delay: const Duration(milliseconds: 400),
                              child: _buildSaveButton(context, state),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// خلفية الميش المتدرجة
  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: widget.readingInfo.color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  /// الهيدر الزجاجي
  Widget _buildHeader() {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E40AF).withOpacity(0.9),
                const Color(0xFF1E40AF).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تسجيل القراءة',
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.readingInfo.titleEn,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
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

  /// كارد معلومات القراءة
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: widget.readingInfo.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: widget.readingInfo.color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: widget.readingInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(widget.readingInfo.icon, color: widget.readingInfo.color, size: 28.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.readingInfo.titleAr,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'أدخل بياناتك بدقة للمتابعة الصحية',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// الحقول حسب نوع القراءة
  List<Widget> _buildFieldsForType() {
    switch (widget.readingInfo.type) {
      case ReadingType.bloodPressure:
        return [
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            child: _buildInputField(
              label: 'الضغط الانقباضي (Systolic)',
              controller: _systolicController,
              unit: 'mmHg',
              icon: Icons.favorite_rounded,
            ),
          ),
          SizedBox(height: 20.h),
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: _buildInputField(
              label: 'الضغط الانبساطي (Diastolic)',
              controller: _diastolicController,
              unit: 'mmHg',
              icon: Icons.favorite_border_rounded,
            ),
          ),
        ];
      case ReadingType.bloodSugar:
        return [
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            child: _buildInputField(
              label: 'مستوى السكر في الدم',
              controller: _sugarController,
              unit: 'mg/dL',
              icon: Icons.water_drop_rounded,
            ),
          ),
        ];
      case ReadingType.weight:
        return [
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            child: _buildInputField(
              label: 'الوزن الحالي',
              controller: _weightController,
              unit: 'kg',
              icon: Icons.monitor_weight_rounded,
            ),
          ),
        ];
      case ReadingType.temperature:
        return [
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            child: _buildInputField(
              label: 'درجة الحرارة',
              controller: _tempController,
              unit: '°C',
              icon: Icons.thermostat_rounded,
            ),
          ),
        ];
    }
  }

  /// حقل إدخال زجاجي
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: EdgeInsets.all(12.r),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2F6BFF),
                  ),
                ),
              ),
              suffixIcon: Icon(icon, color: const Color(0xFF64748B), size: 22.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }

  /// حقل التاريخ والوقت الزجاجي
  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'توقيت القراءة',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: const Color(0xFF2F6BFF), size: 20.r),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(Icons.edit_calendar_rounded, color: const Color(0xFF64748B), size: 20.r),
              ],
            ),
          ),
        ),
      ],
    );
  }


  /// زر الحفظ المتطور
  Widget _buildSaveButton(BuildContext context, HealthState state) {
    final isLoading = state is HealthLoading;
    return Container(
      width: double.infinity,
      height: 58.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2F6BFF),
            const Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6BFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _saveReading(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حفظ القراءة الصحية',
                    style: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Icon(Icons.check_circle_rounded, size: 24),
                ],
              ),
      ),
    );
  }
}
