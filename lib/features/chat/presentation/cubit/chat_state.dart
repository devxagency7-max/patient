import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';

/// State for a single chat surface (either the pharmacist conversation or
/// the AI assistant) — the two are independent: separate message lists,
/// separate loading/connection status, never mixed together.
class ChatThreadState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final bool isConnected;
  final bool isAiTyping;
  final bool isConversationClosed;
  final bool hasMoreHistory;
  final bool loadingMoreHistory;
  final bool isUploadingAttachment;
  final String? errorMessage;

  const ChatThreadState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isAiTyping = false,
    this.isConversationClosed = false,
    this.hasMoreHistory = false,
    this.loadingMoreHistory = false,
    this.isUploadingAttachment = false,
    this.errorMessage,
  });

  ChatThreadState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    bool? isConnected,
    bool? isAiTyping,
    bool? isConversationClosed,
    bool? hasMoreHistory,
    bool? loadingMoreHistory,
    bool? isUploadingAttachment,
    String? errorMessage,
  }) {
    return ChatThreadState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      isConversationClosed: isConversationClosed ?? this.isConversationClosed,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      loadingMoreHistory: loadingMoreHistory ?? this.loadingMoreHistory,
      isUploadingAttachment:
          isUploadingAttachment ?? this.isUploadingAttachment,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        isConnected,
        isAiTyping,
        isConversationClosed,
        hasMoreHistory,
        loadingMoreHistory,
        isUploadingAttachment,
        errorMessage,
      ];
}

class ChatState extends Equatable {
  final ChatThreadState pharmacistChat;
  final ChatThreadState aiChat;

  const ChatState({
    this.pharmacistChat = const ChatThreadState(),
    this.aiChat = const ChatThreadState(),
  });

  ChatState copyWith({ChatThreadState? pharmacistChat, ChatThreadState? aiChat}) {
    return ChatState(
      pharmacistChat: pharmacistChat ?? this.pharmacistChat,
      aiChat: aiChat ?? this.aiChat,
    );
  }

  @override
  List<Object?> get props => [pharmacistChat, aiChat];
}
