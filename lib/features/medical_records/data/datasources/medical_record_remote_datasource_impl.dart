import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/medical_records/data/datasources/medical_record_remote_datasource.dart';
import 'package:pharmacare/features/medical_records/data/models/medical_record_model.dart';

class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final ApiClient apiClient;

  MedicalRecordRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MedicalRecordModel> createMedicalRecord({
    required String uploadedFileId,
    required String type,
    String? title,
    String? recordedAt,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'medical-records',
        data: {
          'uploadedFileId': uploadedFileId,
          'type': type,
          'title': title,
          'recordedAt': recordedAt,
        },
      );

      if (response.data['success'] == true) {
        return MedicalRecordModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create medical record',
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
  Future<List<MedicalRecordModel>> getMedicalRecords({
    String? type,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'medical-records',
        queryParameters: {
          if (type != null && type.isNotEmpty) 'type': type,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => MedicalRecordModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch medical records',
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
  Future<void> deleteMedicalRecord(String id) async {
    try {
      final response = await apiClient.dio.delete('medical-records/$id');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete medical record',
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
