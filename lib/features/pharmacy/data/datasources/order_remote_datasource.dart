import 'package:pharmacare/features/pharmacy/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String pharmacyId,
    required String deliveryAddressId,
    String? prescriptionId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  });
  Future<List<OrderModel>> getMyOrders({
    String? status,
    required int page,
    required int pageSize,
  });
  Future<OrderModel> getOrderDetail(String id);
  Future<void> cancelOrder(String id);
}
