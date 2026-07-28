import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final MedicineEntity medicine;
  final int initialQuantity;
  final Function(int count) onQuantityChanged;

  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
    required this.initialQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;
    final hasImage = med.imageUrl != null && med.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'تفاصيل الدواء',
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
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity Selector (- quantity +)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _decrement,
                    icon: Icon(
                      Icons.remove_rounded,
                      color: _quantity > 1 ? const Color(0xFF1E293B) : Colors.grey,
                      size: 20.sp,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _increment,
                    icon: Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            // Add To Cart Button
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onQuantityChanged(_quantity);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم تحديث السلة: ${med.name} (عدد $_quantity)',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  label: Text(
                    'إضافة إلى السلة ($_quantity)',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Header Image Card
            Container(
              width: double.infinity,
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: hasImage
                        ? Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Image.network(
                              med.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.medication_liquid_rounded,
                                size: 90.sp,
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.medication_liquid_rounded,
                            size: 90.sp,
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                  ),
                  // Badges Top Right
                  Positioned(
                    top: 14.h,
                    right: 14.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (med.requiresPrescription) ...[
                          _badgeTile(
                            text: 'يتطلب روشتة طبية',
                            icon: Icons.assignment_rounded,
                            color: const Color(0xFFFF9F43),
                          ),
                          SizedBox(height: 6.h),
                        ],
                        if (med.isControlled)
                          _badgeTile(
                            text: 'دواء جدول مراقب',
                            icon: Icons.warning_rounded,
                            color: const Color(0xFFFF4757),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Medicine Main Title & Dosage
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: GoogleFonts.cairo(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF08C75A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'متوفر بالصيدليات',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF08C75A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'الجرعة التركيبية: ${med.dosage}',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (med.activeIngredient != null && med.activeIngredient!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.science_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 6.w),
                        Text(
                          'المادة الفعالة: ${med.activeIngredient}',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Specs Quick Chips Grid
            Row(
              children: [
                Expanded(
                  child: _infoChip(
                    label: 'الشكل الدوائي',
                    value: med.form ?? 'أقراص / كبسولات',
                    icon: Icons.medication_rounded,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _infoChip(
                    label: 'التصنيف الطبي',
                    value: med.activeIngredient ?? 'مستحضر طبي',
                    icon: Icons.category_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Usage & Instructions
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوصف وإرشادات الاستخدام',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    med.description != null && med.description!.isNotEmpty
                        ? med.description!
                        : 'يستخدم هذا الدواء وفق الخطة العلاجية المحددة من الطبيب أو الصيدلي المتابع. يرجى الالتزام بمواعيد الجرعات الدقيقة والاحتفاظ بالدواء في مكان بارد وجاف.',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5.sp,
                      height: 1.6,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeTile({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
