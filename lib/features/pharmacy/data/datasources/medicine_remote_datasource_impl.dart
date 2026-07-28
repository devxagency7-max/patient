import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/medicine_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/models/medicine_model.dart';

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final ApiClient apiClient;

  MedicineRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MedicineModel>> searchMedicines({
    String? query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'medicines/search',
        queryParameters: {
          'query': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => MedicineModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to search medicines',
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
  Future<MedicineModel> getMedicineDetail(String id) async {
    try {
      final response = await apiClient.dio.get('medicines/$id');

      if (response.data['success'] == true) {
        return MedicineModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get medicine details',
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
