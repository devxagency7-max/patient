import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السجل السابق',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E2D4A),
            ),
          ),
          SizedBox(height: 14.h),
          ...List.generate(_history.length, (index) {
            return FadeInUp(
              duration: Duration(milliseconds: 600 + (index * 100)),
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _historyCard(_history[index]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _historyCard(HistoryItem item) {
    final Color statusColor = item.wasTaken
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final String statusText = item.wasTaken ? 'تم التناول' : 'تم التعطيل';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.wasTaken ? Icons.check_rounded : Icons.close_rounded,
                    color: statusColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2D4A),
                        ),
                      ),
                      Text(
                        item.dateTime,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8A94A6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Text
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
