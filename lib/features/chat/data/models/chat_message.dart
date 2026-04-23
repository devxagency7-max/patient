/// بيانات الرسالة
class ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

/// الرسائل الوهمية للشات
class ChatRepository {
  static const List<ChatMessage> initialMessages = [
    ChatMessage(
      text: 'مرحبًا! كيف يمكنني مساعدتك اليوم؟',
      time: '10:00 AM',
      isMe: false,
    ),
    ChatMessage(
      text: 'هل يمكنني تناول الأسبرين مع ميتفورمين؟',
      time: '10:02 AM',
      isMe: true,
    ),
    ChatMessage(
      text:
          'نعم، يمكنك تناولهما معًا. لا يوجد تفاعل دوائي بينهما. لكن احرص على تناول الميتفورمين مع الطعام لتجنب اضطرابات المعدة.',
      time: '10:03 AM',
      isMe: false,
    ),
    ChatMessage(
      text: 'شكرًا لك! هل هناك وقت محدد للأسبرين؟',
      time: '10:04 AM',
      isMe: true,
    ),
    ChatMessage(
      text:
          'يفضل تناول الأسبرين في نفس الوقت يوميًا. إذا كان 100mg للوقاية، يمكن تناوله صباحًا بعد الإفطار.',
      time: '10:05 AM',
      isMe: false,
    ),
  ];
}
