import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/devices/data/datasources/device_remote_datasource.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final ApiClient apiClient;

  DeviceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> registerDevice({
    required String deviceType,
    String? deviceName,
    required String fcmToken,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'users/me/devices',
        data: {
          'deviceType': deviceType,
          if (deviceName != null) 'deviceName': deviceName,
          'fcmToken': fcmToken,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['id'] as String? ?? '';
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to register device',
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
  Future<void> unregisterDevice(String deviceId) async {
    try {
      await apiClient.dio.delete('users/me/devices/$deviceId');
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
