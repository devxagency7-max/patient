import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/prescription/data/datasources/prescription_remote_datasource.dart';
import 'package:pharmacare/features/prescription/data/models/prescription_model.dart';

class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final ApiClient apiClient;

  PrescriptionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PrescriptionModel> createPrescription({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> imageUrls = const [],
  }) async {
    try {
      final response = await apiClient.dio.post(
        'prescriptions',
        data: {
          'doctorName': doctorName,
          'clinicName': clinicName,
          'issueDate': issueDate,
          'expiryDate': expiryDate,
          'imageUrls': imageUrls,
        },
      );

      if (response.data['success'] == true) {
        return PrescriptionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create prescription',
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
  Future<List<PrescriptionModel>> getMyPrescriptions({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'prescriptions/me',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => PrescriptionModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch prescriptions',
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
  Future<PrescriptionModel> getPrescriptionById(String id) async {
    try {
      final response = await apiClient.dio.get('prescriptions/$id');

      if (response.data['success'] == true) {
        return PrescriptionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch prescription',
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
