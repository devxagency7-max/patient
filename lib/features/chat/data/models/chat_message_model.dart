import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    super.conversationId,
    super.senderId,
    required super.text,
    super.imageUrl,
    super.messageType,
    required super.sentAt,
    required super.isFromCustomer,
    required super.isFromAi,
    super.isRead,
  });

  /// [currentUserId] is this device's own Firebase UID (see
  /// `ApiClient.currentUserId`) — comparing it against the backend's
  /// `senderId` is the only reliable way to know "is this message mine?".
  /// A prior implementation guessed from `senderName` prefixes, which broke
  /// for any name not literally starting with "Pharm" and misattributed
  /// pharmacist messages to the patient.
  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final rawText = json['text'] as String? ?? json['content'] as String? ?? '';
    final messageType = json['messageType'] as String? ?? 'Text';
    // The backend has no dedicated imageUrl field — an attachment is a
    // message whose content/text IS the file URL, distinguished only by
    // messageType == 'Image'. Route it into imageUrl so the bubble renders
    // it as an image instead of printing the raw link as text.
    final isImage = messageType == 'Image';
    final imageUrl = isImage
        ? (json['imageUrl'] as String? ?? rawText)
        : json['imageUrl'] as String?;
    final text = isImage ? '' : rawText;
    final sentAt =
        json['sentAt'] as String? ??
        json['createdAt'] as String? ??
        DateTime.now().toIso8601String();
    final isFromAi =
        json['isFromAi'] as bool? ?? json['isAI'] as bool? ?? false;
    final senderId = json['senderId'] as String?;
    final isFromCustomer = isFromAi
        ? false
        : (senderId != null && currentUserId != null
              ? senderId == currentUserId
              : (json['isFromCustomer'] as bool? ?? true));

    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String?,
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      messageType: messageType,
      sentAt: sentAt,
      isFromCustomer: isFromCustomer,
      isFromAi: isFromAi,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
