import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/patient_conditions/data/datasources/patient_condition_remote_datasource.dart';
import 'package:pharmacare/features/patient_conditions/data/models/patient_condition_model.dart';

class PatientConditionRemoteDataSourceImpl implements PatientConditionRemoteDataSource {
  final ApiClient apiClient;

  PatientConditionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PatientConditionModel> createCondition({
    required String type,
    required String name,
    String? description,
    String? imageUrl,
    String? diagnosedAt,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'patients/conditions',
        data: {
          'type': type,
          'name': name,
          if (description != null && description.isNotEmpty) 'description': description,
          if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
          if (diagnosedAt != null && diagnosedAt.isNotEmpty) 'diagnosedAt': diagnosedAt,
        },
      );

      if (response.data['success'] == true) {
        return PatientConditionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create condition',
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
  Future<List<PatientConditionModel>> getConditions({
    String? type,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'patients/conditions',
        queryParameters: {
          if (type != null && type.isNotEmpty) 'type': type,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => PatientConditionModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch conditions',
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
  Future<void> deleteCondition(String id) async {
    try {
      final response = await apiClient.dio.delete('patients/conditions/$id');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete condition',
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
