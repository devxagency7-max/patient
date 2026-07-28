import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:pharmacare/features/chat/data/models/chat_message_model.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ChatHistoryResult> getChatHistory({
    required int page,
    required int pageSize,
  }) async {
    try {
      // This app has no conversation-inbox UI: a patient has at most one
      // active pharmacist conversation, and the backend sorts conversations
      // desc by lastMessageAt, so the single most recent item is the one
      // active conversation we need — pageSize 1 is intentional, not a typo.
      final conversationsResponse = await apiClient.dio.get(
        'chat/conversations',
        queryParameters: {'page': 1, 'pageSize': 1},
      );

      if (conversationsResponse.data['success'] == true) {
        final List<dynamic> conversations =
            conversationsResponse.data['data']['items'] ?? [];
        if (conversations.isEmpty) {
          return const ChatHistoryResult(conversationId: null, messages: []);
        }

        final conversationId = conversations.first['id'] as String;
        final conversationStatus = conversations.first['status'] as String?;

        // 2. Fetch messages for that conversation ID
        final response = await apiClient.dio.get(
          'chat/$conversationId/messages',
          queryParameters: {'pageSize': pageSize},
        );

        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          final List<dynamic> items = data['items'] ?? [];
          final currentUserId = apiClient.currentUserId;
          final messages = items
              .map(
                (e) => ChatMessageModel.fromJson(
                  e as Map<String, dynamic>,
                  currentUserId: currentUserId,
                ),
              )
              .toList();
          return ChatHistoryResult(
            conversationId: conversationId,
            conversationStatus: conversationStatus,
            messages: messages,
            nextCursor: data['nextCursor'] as String?,
            hasMore: data['hasMore'] as bool? ?? false,
          );
        } else {
          throw ServerException(
            message: response.data['message'] ?? 'Failed to load messages',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ServerException(
          message:
              conversationsResponse.data['message'] ??
              'Failed to load conversations',
          statusCode: conversationsResponse.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'Text',
  }) async {
    try {
      final response = await apiClient.dio.post(
        'chat/$conversationId/messages',
        data: {'content': content, 'messageType': messageType},
      );

      if (response.data['success'] == true) {
        return ChatMessageModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
          currentUserId: apiClient.currentUserId,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send message',
          statusCode: response.statusCode,
          errorCode: response.data['errorCode'] as String?,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ChatMessageModel> sendAiMessage(String message, {String? conversationId}) async {
    // Contract: this endpoint always returns 200, even when the AI failed
    // internally (it returns an Arabic fallback message in `data.content`
    // instead). The client must never treat that as an error — just show
    // whatever content comes back. The response is the AI reply only (the
    // patient's own message is persisted server-side but not echoed here) —
    // its conversationId is the patient's single, stable AI-conversation id,
    // needed so later sends/history-loads target the same conversation.
    try {
      final response = await apiClient.dio.post(
        'chat/ai-message',
        data: {
          'message': message,
          if (conversationId != null) 'conversationId': conversationId,
        },
      );

      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(data);
      }
      throw ServerException(message: 'Empty AI response');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    }
  }

  @override
  Future<MessagesPageResult> getConversationMessages({
    required String conversationId,
    required int pageSize,
    String? cursor,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'chat/$conversationId/messages',
        queryParameters: {
          'pageSize': pageSize,
          if (cursor != null) 'cursor': cursor,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final List<dynamic> items = data['items'] ?? [];
        final currentUserId = apiClient.currentUserId;
        return MessagesPageResult(
          items: items
              .map(
                (e) => ChatMessageModel.fromJson(
                  e as Map<String, dynamic>,
                  currentUserId: currentUserId,
                ),
              )
              .toList(),
          nextCursor: data['nextCursor'] as String?,
          hasMore: data['hasMore'] as bool? ?? false,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load messages',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StartConversationResult> startConversation({
    required String otherParticipantId,
    String? relatedOrderId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'chat/conversations',
        data: {
          'otherParticipantId': otherParticipantId,
          if (relatedOrderId != null) 'relatedOrderId': relatedOrderId,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return StartConversationResult(
          id: data['id'] as String,
          status: data['status'] as String?,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to start conversation',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ConversationSummaryResult>> getConversations({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'chat/conversations',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items
            .map(
              (e) => ConversationSummaryResult(
                id: e['id'] as String,
                otherParticipantId: e['otherParticipantId'] as String? ?? '',
                status: e['status'] as String?,
              ),
            )
            .toList();
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to load conversations',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markConversationAsRead({required String conversationId}) async {
    try {
      final response = await apiClient.dio.put(
        'chat/conversations/$conversationId/read',
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to mark conversation as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        errorCode: e.response?.data?['errorCode'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
