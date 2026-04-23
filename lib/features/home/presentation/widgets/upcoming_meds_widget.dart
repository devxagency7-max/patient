import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

/// بيانات الدواء
class MedicationItem {
  final String nameAr;
  final String nameEn;
  final String time;
  final String dose;
  final IconData icon;

  const MedicationItem({
    required this.nameAr,
    required this.nameEn,
    required this.time,
    required this.dose,
    this.icon = Icons.medication_rounded,
  });
}

/// قسم الأدوية القادمة
class UpcomingMedsWidget extends StatelessWidget {
  const UpcomingMedsWidget({super.key});

  static const List<MedicationItem> _medications = [
    MedicationItem(
      nameAr: 'أسبرين',
      nameEn: 'Aspirin',
      time: '10:00 AM',
      dose: '100mg',
    ),
    MedicationItem(
      nameAr: 'ميتفورمين',
      nameEn: 'Metformin',
      time: '02:00 PM',
      dose: '500mg',
    ),
    MedicationItem(
      nameAr: 'أوميجا 3',
      nameEn: 'Omega-3',
      time: '08:00 PM',
      dose: '1000mg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // العنوان + عرض الكل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأدوية القادمة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // قائمة الأدوية
          ...List.generate(_medications.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _medications.length - 1 ? 10 : 0,
              ),
              child: _medicationCard(_medications[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _medicationCard(MedicationItem med) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // أيقونة الدواء
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(med.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          // اسم الدواء
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.nameAr,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  med.nameEn,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // الوقت والجرعة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                med.time,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                med.dose,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
