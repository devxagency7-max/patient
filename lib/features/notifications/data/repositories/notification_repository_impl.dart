import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:pharmacare/features/notifications/domain/entities/notification_entity.dart';
import 'package:pharmacare/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<NotificationEntity>>> getNotifications({
    required int page,
    required int pageSize,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(page: page, pageSize: pageSize);
      return ApiSuccess(notifications);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return ApiSuccess(count);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<MarkAllReadEntity>> markAllAsRead() async {
    try {
      final result = await remoteDataSource.markAllAsRead();
      return ApiSuccess(
        MarkAllReadEntity(markedCount: result.markedCount, unreadCount: result.unreadCount),
      );
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
