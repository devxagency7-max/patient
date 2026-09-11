import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';

/// State for the pharmacist conversation thread.
class ChatThreadState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final bool isConnected;
  final bool isConversationClosed;
  final bool hasMoreHistory;
  final bool loadingMoreHistory;
  final bool isUploadingAttachment;
  final String? errorMessage;

  const ChatThreadState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
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
        isConversationClosed,
        hasMoreHistory,
        loadingMoreHistory,
        isUploadingAttachment,
        errorMessage,
      ];
}

class ChatState extends Equatable {
  final ChatThreadState pharmacistChat;

  const ChatState({
    this.pharmacistChat = const ChatThreadState(),
  });

  ChatState copyWith({ChatThreadState? pharmacistChat}) {
    return ChatState(
      pharmacistChat: pharmacistChat ?? this.pharmacistChat,
    );
  }

  @override
  List<Object?> get props => [pharmacistChat];
}
