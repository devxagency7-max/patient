import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  // Null for the AI-assistant thread's own local messages (that thread has
  // no conversationId at all — see ChatCubit.sendAiMessage). Populated from
  // the backend for anything that came through the real pharmacist
  // conversation (REST history or SignalR), so ChatCubit can filter
  // ReceiveMessage events to the conversation it's actually tracking.
  final String? conversationId;
  final String? senderId;
  final String text;
  final String? imageUrl;
  final String messageType;
  final String sentAt;
  final bool isFromCustomer;
  final bool isFromAi;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    this.conversationId,
    this.senderId,
    required this.text,
    this.imageUrl,
    this.messageType = 'Text',
    required this.sentAt,
    required this.isFromCustomer,
    required this.isFromAi,
    this.isRead = false,
  });

  ChatMessageEntity copyWith({bool? isRead}) {
    return ChatMessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      messageType: messageType,
      sentAt: sentAt,
      isFromCustomer: isFromCustomer,
      isFromAi: isFromAi,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    text,
    imageUrl,
    messageType,
    sentAt,
    isFromCustomer,
    isFromAi,
    isRead,
  ];
}
