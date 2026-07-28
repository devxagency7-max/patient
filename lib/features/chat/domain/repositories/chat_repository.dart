import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';

class ChatHistoryEntity {
  final String? conversationId;
  final String? conversationStatus;
  final List<ChatMessageEntity> messages;
  final String? nextCursor;
  final bool hasMore;

  const ChatHistoryEntity({
    required this.conversationId,
    this.conversationStatus,
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
  });
}

class StartConversationEntity {
  final String id;
  final String? status;

  const StartConversationEntity({required this.id, this.status});
}

class MessagesPageEntity {
  final List<ChatMessageEntity> items;
  final String? nextCursor;
  final bool hasMore;

  const MessagesPageEntity({required this.items, this.nextCursor, this.hasMore = false});
}

class ConversationSummaryEntity {
  final String id;
  final String otherParticipantId;
  final String? status;

  const ConversationSummaryEntity({
    required this.id,
    required this.otherParticipantId,
    this.status,
  });
}

abstract class ChatRepository {
  Future<ApiResult<ChatHistoryEntity>> getChatHistory({required int page, required int pageSize});
  Future<ApiResult<ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'Text',
  });
  Future<ApiResult<ChatMessageEntity>> sendAiMessage(String message, {String? conversationId});
  Future<ApiResult<MessagesPageEntity>> getConversationMessages({
    required String conversationId,
    required int pageSize,
    String? cursor,
  });
  Future<ApiResult<StartConversationEntity>> startConversation({
    required String otherParticipantId,
    String? relatedOrderId,
  });
  Future<ApiResult<void>> markConversationAsRead({
    required String conversationId,
  });
  Future<ApiResult<List<ConversationSummaryEntity>>> getConversations({
    required int page,
    required int pageSize,
  });
}
