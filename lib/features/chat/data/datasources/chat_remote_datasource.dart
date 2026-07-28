import 'package:pharmacare/features/chat/data/models/chat_message_model.dart';

class ChatHistoryResult {
  final String? conversationId;
  final String? conversationStatus;
  final List<ChatMessageModel> messages;
  final String? nextCursor;
  final bool hasMore;

  const ChatHistoryResult({
    required this.conversationId,
    this.conversationStatus,
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
  });
}

class StartConversationResult {
  final String id;
  final String? status;

  const StartConversationResult({required this.id, this.status});
}

class MessagesPageResult {
  final List<ChatMessageModel> items;
  final String? nextCursor;
  final bool hasMore;

  const MessagesPageResult({required this.items, this.nextCursor, this.hasMore = false});
}

class ConversationSummaryResult {
  final String id;
  final String otherParticipantId;
  final String? status;

  const ConversationSummaryResult({
    required this.id,
    required this.otherParticipantId,
    this.status,
  });
}

abstract class ChatRemoteDataSource {
  Future<ChatHistoryResult> getChatHistory({required int page, required int pageSize});
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'Text',
  });
  Future<ChatMessageModel> sendAiMessage(String message, {String? conversationId});
  Future<MessagesPageResult> getConversationMessages({
    required String conversationId,
    required int pageSize,
    String? cursor,
  });
  Future<StartConversationResult> startConversation({
    required String otherParticipantId,
    String? relatedOrderId,
  });
  Future<void> markConversationAsRead({
    required String conversationId,
  });
  Future<List<ConversationSummaryResult>> getConversations({
    required int page,
    required int pageSize,
  });
}
