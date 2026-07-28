import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/home/data/datasources/health_insight_remote_datasource.dart';
import 'package:pharmacare/features/home/data/models/health_insight_model.dart';

class HealthInsightRemoteDataSourceImpl implements HealthInsightRemoteDataSource {
  final ApiClient apiClient;

  HealthInsightRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<HealthInsightModel> getHealthInsight() async {
    try {
      final response = await apiClient.dio.post('ai/health-insight');

      if (response.data['success'] == true) {
        return HealthInsightModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to generate health insight',
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
