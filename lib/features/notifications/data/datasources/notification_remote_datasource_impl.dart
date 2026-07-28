import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:pharmacare/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'notifications',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch notifications',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.dio.get('notifications/unread-count');

      if (response.data['success'] == true) {
        return response.data['data'] as int? ?? 0;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch unread count',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final response = await apiClient.dio.put('notifications/$id/read');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark notification as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarkAllReadResult> markAllAsRead() async {
    try {
      final response = await apiClient.dio.put('notifications/read-all');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return MarkAllReadResult(
          markedCount: data['markedCount'] as int? ?? 0,
          unreadCount: data['unreadCount'] as int? ?? 0,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark all notifications as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
