import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

/// كارد الدواء في الـ Grid بنمط زجاجي فاخر مع عداد الجرعات والكميات
class MedicineCard extends StatelessWidget {
  final MedicineEntity medicine;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTapCard;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.quantity = 0,
    required this.onAddToCart,
    this.onIncrement,
    this.onDecrement,
    this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الصورة / الأيقونة
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.network(
                                medicine.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.medication_liquid_rounded,
                                  size: 48.sp,
                                  color: const Color(0xFF2F6BFF).withOpacity(0.2),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.medication_liquid_rounded,
                              size: 48.sp,
                              color: const Color(0xFF2F6BFF).withOpacity(0.2),
                            ),
                    ),
                    // بادج روشتة
                    if (medicine.requiresPrescription)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9F43).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFFF9F43).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.assignment_rounded, color: Color(0xFFFF9F43), size: 10),
                              SizedBox(width: 3.w),
                              Text(
                                'روشتة',
                                style: GoogleFonts.cairo(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFF9F43),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // بادج جدول
                    if (medicine.isControlled)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4757).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_rounded, color: Color(0xFFFF4757), size: 10),
                              SizedBox(width: 3.w),
                              Text(
                                'رقابة',
                                style: GoogleFonts.cairo(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFF4757),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // تفاصيل الدواء والعداد
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'الجرعة: ${medicine.dosage}',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'تسعير صيدلي',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2F6BFF),
                          ),
                        ),
                      ),
                      // إذا كانت الكمية أكبر من 0 يظهر العداد مباشرة بالكارت
                      if (quantity > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF5FC),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFF2F6BFF).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: onDecrement ?? onAddToCart,
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.all(3.r),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF2F6BFF),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(
                                  '$quantity',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: onIncrement ?? onAddToCart,
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.all(3.r),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF2F6BFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // زر إضافة للسلة الابتدائي
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2F6BFF), Color(0xFF1E40AF)],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2F6BFF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
