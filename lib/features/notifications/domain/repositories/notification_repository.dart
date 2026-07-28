import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/notifications/domain/entities/notification_entity.dart';

class MarkAllReadEntity {
  final int markedCount;
  final int unreadCount;

  const MarkAllReadEntity({required this.markedCount, required this.unreadCount});
}

abstract class NotificationRepository {
  Future<ApiResult<List<NotificationEntity>>> getNotifications({
    required int page,
    required int pageSize,
  });

  Future<ApiResult<int>> getUnreadCount();

  Future<ApiResult<void>> markAsRead(String id);

  Future<ApiResult<MarkAllReadEntity>> markAllAsRead();
}
