import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

/// كارد الدواء في الـ Grid بنمط زجاجي فاخر
class MedicineCard extends StatelessWidget {
  final MedicineEntity medicine;
  final VoidCallback onAddToCart;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
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
                  // صورة الدواء (لو متوفرة) أو أيقونة الدواء المركزية
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
                  // بادج "روشتة"
                  if (medicine.requiresPrescription)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F43).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFFF9F43).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_rounded, color: Color(0xFFFF9F43), size: 10),
                            SizedBox(width: 4.w),
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
                  // بادج "جدول" خاضع للرقابة
                  if (medicine.isControlled)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4757).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_rounded, color: Color(0xFFFF4757), size: 10),
                            SizedBox(width: 4.w),
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

          // تفاصيل الدواء
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
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
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'تسعير صيدلي',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2F6BFF),
                        ),
                      ),
                    ),
                    // زر الإضافة الدائري
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
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
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
