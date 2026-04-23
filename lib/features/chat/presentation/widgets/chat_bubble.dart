import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/features/chat/data/models/chat_message.dart';

/// فقاعة الرسالة
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.isMe ? 0 : 50,
          right: message.isMe ? 50 : 0,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            // الفقاعة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isMe
                    ? const LinearGradient(
                        colors: [Color(0xFF2F6BFF), Color(0xFF4A7FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1E2D4A), Color(0xFF253754)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 4 : 18),
                  bottomRight: Radius.circular(message.isMe ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (message.isMe
                                ? const Color(0xFF2F6BFF)
                                : const Color(0xFF1E2D4A))
                            .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            // الوقت
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
              child: Text(
                message.time,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
