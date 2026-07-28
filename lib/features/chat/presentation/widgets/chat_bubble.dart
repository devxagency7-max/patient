import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromCustomer;
    final isAi = message.isFromAi;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 0.75.sw,
        ),
        margin: EdgeInsets.only(
          bottom: 12.h,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // اسم المرسل إذا لم يكن المريض
            if (!isMe)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h, left: 6.w),
                child: Text(
                  isAi ? 'مساعد الذكاء الاصطناعي ✨' : 'الصيدلي المتابع',
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isAi ? AppColors.primaryGreen : AppColors.primary,
                  ),
                ),
              ),
            // كارد الفقاعة
            Container(
              decoration: BoxDecoration(
                gradient: isMe
                    ? AppColors.primaryGradient
                    : isAi
                        ? LinearGradient(colors: [const Color(0xFF00C48C).withOpacity(0.85), const Color(0xFF34D399).withOpacity(0.85)])
                        : null,
                color: (isMe || isAi) ? null : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                  bottomLeft: Radius.circular(isMe ? 14.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 14.r),
                ),
                border: Border.all(
                  color: isMe
                      ? Colors.white.withOpacity(0.15)
                      : isAi
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          message.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    if (message.text.isNotEmpty)
                      Text(
                        message.text,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: (isMe || isAi) ? Colors.white : const Color(0xFF1E2D4A),
                          height: 1.5,
                        ),
                        textAlign: isMe ? TextAlign.right : TextAlign.left,
                        textDirection: TextDirection.rtl,
                      ),
                  ],
                ),
              ),
            ),
            // وقت الإرسال + حالة القراءة
            Padding(
              padding: EdgeInsets.only(top: 4.h, left: 6.w, right: 6.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.sentAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A94A6).withOpacity(0.8),
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14.r,
                      color: message.isRead
                          ? AppColors.primary
                          : const Color(0xFF8A94A6).withOpacity(0.8),
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

  String _formatTime(String isoStr) {
    try {
      final date = DateTime.parse(isoStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }
}
