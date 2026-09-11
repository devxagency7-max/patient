import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/chat/data/services/chat_signalr_service.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';
import 'package:pharmacare/features/chat/domain/repositories/chat_repository.dart';
import 'package:pharmacare/features/chat/presentation/cubit/chat_state.dart';
import 'package:pharmacare/features/file_upload/domain/repositories/file_repository.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';
import 'package:pharmacare/features/pharmacist/domain/repositories/pharmacist_repository.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:uuid/uuid.dart';

/// Drives the pharmacist conversation thread for this screen (REST +
/// SignalR).
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final ChatSignalRService signalRService;
  final FileRepository fileRepository;
  final PharmacistRepository pharmacistRepository;
  final ApiClient apiClient;

  String? _conversationId;
  String? _nextCursor;
  static const int _pageSize = 20;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionStatusSubscription;
  StreamSubscription? _conversationReadSubscription;

  ChatCubit({
    required this.chatRepository,
    required this.signalRService,
    required this.fileRepository,
    required this.pharmacistRepository,
    required this.apiClient,
  }) : super(const ChatState()) {
    _initSignalR();
  }

  void _initSignalR() {
    _messageSubscription = signalRService.messageStream.listen((message) {
      // Only two shapes of ReceiveMessage are legitimate here: (a) a message
      // explicitly tagged with this exact pharmacist conversationId, or
      // (b) the automatic "AI Fallback" reply (isFromAi:true), which is
      // posted into this same conversation by design when the pharmacist
      // doesn't answer in time. Anything else must NOT be accepted into the
      // pharmacist thread.
      final belongsHere = message.conversationId == _conversationId ||
          (message.conversationId == null && message.isFromAi);
      if (!belongsHere) {
        return;
      }
      final thread = state.pharmacistChat;
      // The sender's own SignalR echo of a message they just sent arrives
      // after the optimistic insert in sendMessage() already replaced the
      // temp entry with this same server id — skip it here to avoid a
      // second, duplicate bubble.
      final isDuplicateById = thread.messages.any((m) => m.id == message.id);
      // Defensive fallback: if the backend ever emits ReceiveMessage twice
      // for the same logical message under two different ids, id-based
      // dedup above won't catch it. Treat same sender + same text arriving
      // within a couple seconds of an existing message as the same message.
      final isDuplicateByContent = thread.messages.any(
        (m) =>
            message.senderId != null &&
            m.senderId == message.senderId &&
            m.text == message.text &&
            m.imageUrl == message.imageUrl &&
            (DateTime.tryParse(m.sentAt)
                        ?.difference(
                          DateTime.tryParse(message.sentAt) ?? DateTime.now(),
                        )
                        .abs() ??
                    Duration.zero) <
                const Duration(seconds: 3),
      );
      if (isDuplicateById || isDuplicateByContent) return;
      emit(
        state.copyWith(
          pharmacistChat: thread.copyWith(
            messages: [message, ...thread.messages],
          ),
        ),
      );
    });

    _connectionStatusSubscription = signalRService.connectionStatusStream
        .listen((status) {
          final isConnected = status == HubConnectionState.Connected;
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                isConnected: isConnected,
              ),
            ),
          );
        });

    _conversationReadSubscription = signalRService.conversationReadStream
        .listen((event) {
          if (event.conversationId != _conversationId) return;
          final thread = state.pharmacistChat;
          final updated = thread.messages
              .map(
                (m) => m.isFromCustomer && !m.isRead
                    ? m.copyWith(isRead: true)
                    : m,
              )
              .toList();
          emit(
            state.copyWith(pharmacistChat: thread.copyWith(messages: updated)),
          );
        });
  }

  /// Loads the pharmacist conversation thread.
  Future<void> connectAndLoadHistory({
    String? pharmacistId,
    String? relatedOrderId,
  }) async {
    emit(
      state.copyWith(
        pharmacistChat: state.pharmacistChat.copyWith(
          isLoading: true,
          errorMessage: null,
        ),
      ),
    );
    await signalRService.connect();

    String? conversationId = _conversationId;
    // Set only when this call just created/found the conversation via
    // startConversation below — carries its `status` through to the emit,
    // since getConversationMessages's response has no conversation-level
    // status field to fall back on.
    String? startStatus;

    if (pharmacistId != null) {
      final startResult = await chatRepository.startConversation(
        otherParticipantId: pharmacistId,
        relatedOrderId: relatedOrderId,
      );
      switch (startResult) {
        case ApiSuccess(:final data):
          conversationId = data.id;
          _conversationId = conversationId;
          startStatus = data.status;
        case ApiFailure(:final failure):
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                isLoading: false,
                errorMessage: failure.message,
              ),
            ),
          );
          return;
      }
    }

    if (conversationId != null) {
      final result = await chatRepository.getConversationMessages(
        conversationId: conversationId,
        pageSize: _pageSize,
      );
      if (isClosed) return;
      switch (result) {
        case ApiSuccess(:final data):
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                messages: List<ChatMessageEntity>.from(data.items),
                isLoading: false,
                isConversationClosed: startStatus != null
                    ? startStatus.toLowerCase() == 'closed'
                    : state.pharmacistChat.isConversationClosed,
                hasMoreHistory: data.hasMore,
              ),
            ),
          );
          _nextCursor = data.nextCursor;
          unawaited(
            chatRepository.markConversationAsRead(
              conversationId: conversationId,
            ),
          );
          unawaited(signalRService.joinConversation(conversationId));
        case ApiFailure(:final failure):
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                isLoading: false,
                errorMessage: failure.message,
              ),
            ),
          );
      }
    } else {
      // GET /chat/conversations mixes the pharmacist conversation together
      // with the AI thread and any order-related ones, with no type
      // distinction — "most recent" is not reliably the pharmacist
      // conversation (confirmed with backend after it caused messages to
      // leak between threads). GET /patients/my-requests is the reliable
      // source: its Active entry's conversationId is exactly this one, and
      // is null only when neither side has sent a first message yet, in
      // which case startConversation (idempotent) creates/fetches it.
      final requestsResult = await pharmacistRepository.getMyRequests();
      if (isClosed) return;

      switch (requestsResult) {
        case ApiFailure(:final failure):
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                isLoading: false,
                errorMessage: failure.message,
              ),
            ),
          );
          return;
        case ApiSuccess(:final data):
          AssignmentRequestEntity? active;
          for (final r in data) {
            if (r.status == 'Active') {
              active = r;
              break;
            }
          }
          if (active == null) {
            // No pharmacist relationship at all — nothing to load.
            emit(
              state.copyWith(
                pharmacistChat: state.pharmacistChat.copyWith(
                  isLoading: false,
                ),
              ),
            );
            return;
          }

          String resolvedConversationId;
          if (active.conversationId != null) {
            resolvedConversationId = active.conversationId!;
          } else {
            final startResult = await chatRepository.startConversation(
              otherParticipantId: active.pharmacistId,
            );
            if (isClosed) return;
            switch (startResult) {
              case ApiSuccess(data: final startData):
                resolvedConversationId = startData.id;
              case ApiFailure(:final failure):
                emit(
                  state.copyWith(
                    pharmacistChat: state.pharmacistChat.copyWith(
                      isLoading: false,
                      errorMessage: failure.message,
                    ),
                  ),
                );
                return;
            }
          }

          _conversationId = resolvedConversationId;
          final messagesResult = await chatRepository.getConversationMessages(
            conversationId: resolvedConversationId,
            pageSize: _pageSize,
          );
          if (isClosed) return;
          switch (messagesResult) {
            case ApiSuccess(:final data):
              emit(
                state.copyWith(
                  pharmacistChat: state.pharmacistChat.copyWith(
                    messages: List<ChatMessageEntity>.from(data.items),
                    isLoading: false,
                    // The assignment feeding this branch is always status
                    // "Active" (Terminated ones are filtered out above), so
                    // the conversation can't be closed here.
                    isConversationClosed: false,
                    hasMoreHistory: data.hasMore,
                  ),
                ),
              );
              _nextCursor = data.nextCursor;
              unawaited(
                chatRepository.markConversationAsRead(
                  conversationId: resolvedConversationId,
                ),
              );
              unawaited(
                signalRService.joinConversation(resolvedConversationId),
              );
            case ApiFailure(:final failure):
              emit(
                state.copyWith(
                  pharmacistChat: state.pharmacistChat.copyWith(
                    isLoading: false,
                    errorMessage: failure.message,
                  ),
                ),
              );
          }
      }
    }
  }

  Future<void> loadOlderMessages() async {
    final conversationId = _conversationId;
    final thread = state.pharmacistChat;
    if (conversationId == null ||
        !thread.hasMoreHistory ||
        thread.loadingMoreHistory ||
        _nextCursor == null) {
      return;
    }

    emit(
      state.copyWith(pharmacistChat: thread.copyWith(loadingMoreHistory: true)),
    );

    final result = await chatRepository.getConversationMessages(
      conversationId: conversationId,
      pageSize: _pageSize,
      cursor: _nextCursor,
    );
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        _nextCursor = data.nextCursor;
        emit(
          state.copyWith(
            pharmacistChat: state.pharmacistChat.copyWith(
              messages: [...state.pharmacistChat.messages, ...data.items],
              loadingMoreHistory: false,
              hasMoreHistory: data.hasMore,
            ),
          ),
        );
      case ApiFailure():
        emit(
          state.copyWith(
            pharmacistChat: state.pharmacistChat.copyWith(
              loadingMoreHistory: false,
            ),
          ),
        );
    }
  }

  /// Sends a message in the real pharmacist conversation. Returns whether
  /// the send actually succeeded, so the caller (the composer) knows whether
  /// it's safe to clear the typed text.
  Future<bool> sendMessage(String text, {String? imageUrl}) async {
    final conversationId = _conversationId;
    if (conversationId == null) {
      emit(
        state.copyWith(
          pharmacistChat: state.pharmacistChat.copyWith(
            errorMessage: 'لا توجد محادثة نشطة مع الصيدلية حالياً',
          ),
        ),
      );
      return false;
    }

    final thread = state.pharmacistChat;
    final tempId = const Uuid().v4();
    final clientMsg = ChatMessageEntity(
      id: tempId,
      conversationId: conversationId,
      // Must be set so the SignalR listener's content-based dedup (senderId
      // + text + close timestamp) can recognize this device's own echoed
      // message if it arrives before the REST response below does — without
      // it, the echo used to slip through as a second, duplicate bubble.
      senderId: apiClient.currentUserId,
      text: text,
      imageUrl: imageUrl,
      sentAt: DateTime.now().toIso8601String(),
      isFromCustomer: true,
      isFromAi: false,
    );
    emit(
      state.copyWith(
        pharmacistChat: thread.copyWith(
          messages: [clientMsg, ...thread.messages],
        ),
      ),
    );

    final contentToSend = imageUrl ?? text;
    final result = await chatRepository.sendMessage(
      conversationId: conversationId,
      content: contentToSend,
      messageType: imageUrl != null ? 'Image' : 'Text',
    );

    if (isClosed) return false;
    switch (result) {
      case ApiSuccess(:final data):
        // Swap the optimistic temp entry for the server's real message (real
        // id/senderId/readAt) so the later SignalR echo's dedup-by-id check
        // recognizes it and doesn't add a second bubble.
        final updated = state.pharmacistChat.messages
            .map((m) => m.id == tempId ? data : m)
            .toList();
        emit(
          state.copyWith(
            pharmacistChat: state.pharmacistChat.copyWith(messages: updated),
          ),
        );
        return true;
      case ApiFailure(:final failure):
        // The send was rejected server-side — drop the optimistic bubble so
        // the conversation never shows a message as delivered when it
        // wasn't; the patient would otherwise have no way to tell it failed.
        final withoutFailed = state.pharmacistChat.messages
            .where((m) => m.id != tempId)
            .toList();
        if (failure is ConversationClosedFailure) {
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                messages: withoutFailed,
                isConversationClosed: true,
              ),
            ),
          );
        } else {
          emit(
            state.copyWith(
              pharmacistChat: state.pharmacistChat.copyWith(
                messages: withoutFailed,
                errorMessage: failure.message,
              ),
            ),
          );
        }
        return false;
    }
  }

  /// Uploads an image attachment (POST /api/files/upload, type
  /// "ChatAttachment") and sends it as a message in the pharmacist
  /// conversation via the same [sendMessage] path used for text — the
  /// server's returned file URL becomes the message's imageUrl. AI-thread
  /// attachments are out of scope: this only ever touches pharmacistChat.
  Future<bool> sendAttachment(File file) async {
    final conversationId = _conversationId;
    if (conversationId == null) {
      emit(
        state.copyWith(
          pharmacistChat: state.pharmacistChat.copyWith(
            errorMessage: 'لا توجد محادثة نشطة مع الصيدلية حالياً',
          ),
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        pharmacistChat: state.pharmacistChat.copyWith(
          isUploadingAttachment: true,
        ),
      ),
    );

    final uploadResult = await fileRepository.uploadFile(
      file: file,
      type: 'ChatAttachment',
    );
    if (isClosed) return false;

    switch (uploadResult) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            pharmacistChat: state.pharmacistChat.copyWith(
              isUploadingAttachment: false,
            ),
          ),
        );
        return sendMessage('', imageUrl: data.url);
      case ApiFailure(:final failure):
        emit(
          state.copyWith(
            pharmacistChat: state.pharmacistChat.copyWith(
              isUploadingAttachment: false,
              errorMessage: failure.message,
            ),
          ),
        );
        return false;
    }
  }

  @override
  Future<void> close() async {
    if (_conversationId != null) {
      await signalRService.leaveConversation(_conversationId!);
    }
    _messageSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _conversationReadSubscription?.cancel();
    await signalRService.disconnect();
    return super.close();
  }
}
