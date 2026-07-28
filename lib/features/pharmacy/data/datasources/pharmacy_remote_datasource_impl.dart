import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/pharmacy_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/models/nearby_pharmacy_model.dart';
import 'package:pharmacare/features/pharmacy/data/models/pharmacy_branch_model.dart';
import 'package:pharmacare/features/pharmacy/data/models/pharmacy_model.dart';

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final ApiClient apiClient;

  PharmacyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<String>> getGovernorates() async {
    try {
      final response = await apiClient.dio.get('pharmacies/governorates');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => e as String).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch governorates',
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
  Future<List<PharmacyModel>> getPharmacies({
    String? governorate,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'pharmacies',
        queryParameters: {
          if (governorate != null && governorate.isNotEmpty) 'governorate': governorate,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => PharmacyModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch pharmacies',
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
  Future<PharmacyModel> getPharmacyDetail(String id) async {
    try {
      final response = await apiClient.dio.get('pharmacies/$id');

      if (response.data['success'] == true) {
        return PharmacyModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch pharmacy',
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
  Future<List<PharmacyBranchModel>> getPharmacyBranches(String pharmacyId) async {
    try {
      final response = await apiClient.dio.get('pharmacies/$pharmacyId/branches');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => PharmacyBranchModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch branches',
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
  Future<List<NearbyPharmacyModel>> getNearbyPharmacies({
    required double lat,
    required double lng,
    double radius = 10.0,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'pharmacies/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => NearbyPharmacyModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch nearby pharmacies',
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
