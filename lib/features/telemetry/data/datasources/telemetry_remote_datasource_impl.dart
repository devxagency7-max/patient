import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/telemetry/data/datasources/telemetry_remote_datasource.dart';

class TelemetryRemoteDataSourceImpl implements TelemetryRemoteDataSource {
  final ApiClient apiClient;

  TelemetryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> sendTelemetry({required String feature, String? details}) async {
    try {
      await apiClient.dio.post(
        'users/telemetry',
        data: {
          'feature': feature,
          if (details != null) 'details': details,
        },
      );
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
