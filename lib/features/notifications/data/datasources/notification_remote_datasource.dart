import 'package:pharmacare/features/notifications/data/models/notification_model.dart';

class MarkAllReadResult {
  final int markedCount;
  final int unreadCount;

  const MarkAllReadResult({required this.markedCount, required this.unreadCount});
}

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int page,
    required int pageSize,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<MarkAllReadResult> markAllAsRead();
}
