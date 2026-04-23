import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';

/// بيانات سجل التذكيرات السابقة
class HistoryItem {
  final String name;
  final String dateTime;
  final bool wasTaken; // true = تم التناول، false = تم التعطيل

  const HistoryItem({
    required this.name,
    required this.dateTime,
    required this.wasTaken,
  });
}

/// قسم السجل السابق
class ReminderHistoryWidget extends StatelessWidget {
  const ReminderHistoryWidget({super.key});

  static const List<HistoryItem> _history = [
    HistoryItem(
      name: 'فيتامين د',
      dateTime: '08:00 - 2026/3/17',
      wasTaken: true,
    ),
    HistoryItem(name: 'أسبرين', dateTime: '10:00 - 2026/3/6', wasTaken: true),
    HistoryItem(
      name: 'ميتفورمين',
      dateTime: '14:00 - 2026/3/6',
      wasTaken: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السجل السابق',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_history.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _history.length - 1 ? 10 : 0,
              ),
              child: _historyCard(_history[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _historyCard(HistoryItem item) {
    final Color statusColor = item.wasTaken
        ? const Color(0xFF00C48C)
        : const Color(0xFFFF4757);
    final String statusText = item.wasTaken ? 'تم التناول' : 'تم التعطيل';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحالة (صح أو X)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.wasTaken ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // اسم الدواء والتاريخ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // نص الحالة
          Text(
            statusText,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
