import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<ApiResult<OrderEntity>> createOrder({
    required String pharmacyId,
    required String deliveryAddressId,
    String? prescriptionId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  });
  Future<ApiResult<List<OrderEntity>>> getMyOrders({
    String? status,
    required int page,
    required int pageSize,
  });
  Future<ApiResult<OrderEntity>> getOrderDetail(String id);
  Future<ApiResult<void>> cancelOrder(String id);
}
