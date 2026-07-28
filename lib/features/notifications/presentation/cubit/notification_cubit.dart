import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/notifications/domain/repositories/notification_repository.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationCubit({required this.notificationRepository}) : super(NotificationInitial());

  Future<void> fetchUnreadCount() async {
    final result = await notificationRepository.getUnreadCount();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final current = state;
        if (current is NotificationLoaded) {
          emit(current.copyWith(unreadCount: data));
        } else {
          emit(NotificationLoaded(notifications: const [], unreadCount: data));
        }
      case ApiFailure():
        break;
    }
  }

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());

    final result = await notificationRepository.getNotifications(page: 1, pageSize: 20);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final unreadCount = data.where((n) => !n.isRead).length;
        emit(NotificationLoaded(notifications: data, unreadCount: unreadCount));
      case ApiFailure(:final failure):
        emit(NotificationError(failure.message));
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final result = await notificationRepository.markAsRead(id);
    if (isClosed) return;
    if (result is ApiSuccess) {
      final updated = current.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      final unreadCount = updated.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications: updated, unreadCount: unreadCount));
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final result = await notificationRepository.markAllAsRead();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(NotificationLoaded(notifications: updated, unreadCount: data.unreadCount));
      case ApiFailure():
        break;
    }
  }

  /// Loads the list then immediately marks everything read in one call — the
  /// screen's entry point. Sequential (not fired in parallel) so
  /// [markAllAsRead]'s `current is NotificationLoaded` check always sees the
  /// just-fetched list instead of racing it.
  Future<void> openNotifications() async {
    await fetchNotifications();
    await markAllAsRead();
  }
}
