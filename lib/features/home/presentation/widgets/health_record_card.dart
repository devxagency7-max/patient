import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

/// كارد السجل الصحي
class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'سجلك الصحي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'آخر تحديث: اليوم 9:30 صباحاً',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            // الإحصائيات
            Row(
              children: [
                _statItem(
                  value: '12',
                  label: 'قراءة صحية',
                  color: AppColors.primary,
                ),
                _divider(),
                _statItem(
                  value: '5',
                  label: 'أدوية نشطة',
                  color: const Color(0xFF00C48C),
                ),
                _divider(),
                _statItem(
                  value: '3',
                  label: 'تحاليل',
                  color: const Color(0xFFFF9F43),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.textSecondary.withValues(alpha: 0.15),
    );
  }
}
