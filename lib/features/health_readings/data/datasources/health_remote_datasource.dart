import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/health_readings/data/models/health_reading_model.dart';

abstract class HealthRemoteDataSource {
  Future<HealthReadingModel> addHealthReading({
    required String type,
    required double value,
    required DateTime recordedAt,
  });

  Future<List<HealthReadingModel>> getHealthReadings({
    required int page,
    required int pageSize,
  });

  Future<List<HealthHistoryModel>> getHealthHistory();
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final ApiClient apiClient;

  HealthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<HealthReadingModel> addHealthReading({
    required String type,
    required double value,
    required DateTime recordedAt,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'health-readings',
        data: {
          'type': type,
          'value': value,
          'recordedAt': recordedAt.toIso8601String(),
        },
      );

      if (response.data['success'] == true) {
        return HealthReadingModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to add reading',
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
  Future<List<HealthReadingModel>> getHealthReadings({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'health-readings',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final dynamic data = response.data['data'];
        final List<dynamic> items = data is Map<String, dynamic>
            ? (data['items'] as List<dynamic>? ?? [])
            : (data as List<dynamic>? ?? []);
        return items.map((e) => HealthReadingModel.fromJson(e)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch readings');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<HealthHistoryModel>> getHealthHistory() async {
    try {
      final response = await apiClient.dio.get('health-readings/history');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => HealthHistoryModel.fromJson(e)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch history');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
