import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/profile/data/datasources/address_remote_datasource.dart';
import 'package:pharmacare/features/profile/data/models/address_model.dart';

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await apiClient.dio.get('users/me/addresses');

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => AddressModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get addresses',
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
  Future<AddressModel> addAddress({
    required String street,
    required String city,
    required String governorate,
    String? additionalInfo,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'users/me/addresses',
        data: {
          'street': street,
          'city': city,
          'governorate': governorate,
          'additionalInfo': additionalInfo,
          'latitude': latitude,
          'longitude': longitude,
          'isDefault': isDefault,
        },
      );

      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to add address',
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
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final response = await apiClient.dio.patch(
        'users/me/addresses/$addressId/default',
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to set default address',
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
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await apiClient.dio.delete(
        'users/me/addresses/$addressId',
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete address',
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
