import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/pharmacist/data/datasources/pharmacist_remote_datasource.dart';
import 'package:pharmacare/features/pharmacist/data/models/assignment_request_model.dart';
import 'package:pharmacare/features/pharmacist/data/models/pharmacist_model.dart';

class PharmacistRemoteDataSourceImpl implements PharmacistRemoteDataSource {
  final ApiClient apiClient;

  PharmacistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PharmacistModel>> getPharmacists() async {
    try {
      final response = await apiClient.dio.get('patients/pharmacists');

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => PharmacistModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get pharmacists',
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
  Future<void> requestPharmacist({required String pharmacistId}) async {
    try {
      final response = await apiClient.dio.post(
        'patients/request-pharmacist',
        data: {
          'pharmacistId': pharmacistId,
        },
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to request care from pharmacist',
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
  Future<List<AssignmentRequestModel>> getMyRequests() async {
    try {
      final response = await apiClient.dio.get('patients/my-requests');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => AssignmentRequestModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch requests',
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
  Future<void> cancelRequest(String requestId) async {
    try {
      final response = await apiClient.dio.delete('patients/requests/$requestId/cancel');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to cancel request',
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
  Future<void> terminateRelationship(String requestId) async {
    try {
      final response = await apiClient.dio.put('patients/requests/$requestId/terminate');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to terminate relationship',
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
