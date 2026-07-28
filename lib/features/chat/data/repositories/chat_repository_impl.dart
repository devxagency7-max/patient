import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';
import 'package:pharmacare/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<ChatHistoryEntity>> getChatHistory({
    required int page,
    required int pageSize,
  }) async {
    try {
      final history = await remoteDataSource.getChatHistory(
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(
        ChatHistoryEntity(
          conversationId: history.conversationId,
          conversationStatus: history.conversationStatus,
          messages: history.messages,
          nextCursor: history.nextCursor,
          hasMore: history.hasMore,
        ),
      );
    } on ServerException catch (e) {
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'Text',
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        messageType: messageType,
      );
      return ApiSuccess(message);
    } on ServerException catch (e) {
      // Backend contract: a Closed conversation is the only case that sets
      // errorCode "CONVERSATION_CLOSED" — a stable, language-independent
      // signal, unlike matching on the free-form (and Arabic-first) message
      // text or assuming every 400 on this endpoint means "closed".
      if (e.errorCode == 'CONVERSATION_CLOSED') {
        return ApiFailure(ConversationClosedFailure(message: e.message));
      }
      if (e.statusCode == 403) {
        return ApiFailure(ForbiddenFailure(message: e.message));
      }
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<ChatMessageEntity>> sendAiMessage(
    String message, {
    String? conversationId,
  }) async {
    try {
      final reply = await remoteDataSource.sendAiMessage(
        message,
        conversationId: conversationId,
      );
      return ApiSuccess(reply);
    } on ServerException catch (e) {
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<MessagesPageEntity>> getConversationMessages({
    required String conversationId,
    required int pageSize,
    String? cursor,
  }) async {
    try {
      final page = await remoteDataSource.getConversationMessages(
        conversationId: conversationId,
        pageSize: pageSize,
        cursor: cursor,
      );
      return ApiSuccess(
        MessagesPageEntity(
          items: page.items,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        ),
      );
    } on ServerException catch (e) {
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<StartConversationEntity>> startConversation({
    required String otherParticipantId,
    String? relatedOrderId,
  }) async {
    try {
      final result = await remoteDataSource.startConversation(
        otherParticipantId: otherParticipantId,
        relatedOrderId: relatedOrderId,
      );
      return ApiSuccess(
        StartConversationEntity(id: result.id, status: result.status),
      );
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return ApiFailure(
          ForbiddenFailure(
            message: e.message.isEmpty
                ? 'انتهت العلاقة مع هذا المستخدم، لا يمكنك بدء محادثة جديدة.'
                : e.message,
          ),
        );
      }
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markConversationAsRead({
    required String conversationId,
  }) async {
    try {
      await remoteDataSource.markConversationAsRead(
        conversationId: conversationId,
      );
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ConversationSummaryEntity>>> getConversations({
    required int page,
    required int pageSize,
  }) async {
    try {
      final results = await remoteDataSource.getConversations(
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(
        results
            .map(
              (r) => ConversationSummaryEntity(
                id: r.id,
                otherParticipantId: r.otherParticipantId,
                status: r.status,
              ),
            )
            .toList(),
      );
    } on ServerException catch (e) {
      return ApiFailure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
