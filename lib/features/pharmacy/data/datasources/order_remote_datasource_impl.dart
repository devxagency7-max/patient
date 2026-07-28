import 'package:dio/dio.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/order_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/models/order_model.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<OrderModel> createOrder({
    required String pharmacyId,
    required String deliveryAddressId,
    String? prescriptionId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'orders',
        data: {
          'pharmacyId': pharmacyId,
          'deliveryAddressId': deliveryAddressId,
          'prescriptionId': prescriptionId,
          if (deliveryNotes != null && deliveryNotes.isNotEmpty) 'deliveryNotes': deliveryNotes,
          'items': items,
        },
      );

      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create order',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to create order';
      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          msg = data['message'].toString();
        }
        if (data['errors'] != null) {
          msg += ' (${data['errors']})';
        }
      } else if (e.message != null) {
        msg = e.message!;
      }
      throw ServerException(
        message: msg,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders({
    String? status,
    required int page,
    required int pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortDirection': 'desc',
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiClient.dio.get(
        'orders/my',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get orders',
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
  Future<OrderModel> getOrderDetail(String id) async {
    try {
      final response = await apiClient.dio.get('orders/$id');

      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get order detail',
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
  Future<void> cancelOrder(String id) async {
    try {
      final response = await apiClient.dio.delete('orders/$id/cancel');

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to cancel order',
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
