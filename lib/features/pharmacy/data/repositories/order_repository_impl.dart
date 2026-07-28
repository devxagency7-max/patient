import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/order_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<OrderEntity>> createOrder({
    required String pharmacyId,
    required String deliveryAddressId,
    String? prescriptionId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        pharmacyId: pharmacyId,
        deliveryAddressId: deliveryAddressId,
        prescriptionId: prescriptionId,
        deliveryNotes: deliveryNotes,
        items: items,
      );
      return ApiSuccess(order);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<OrderEntity>>> getMyOrders({
    String? status,
    required int page,
    required int pageSize,
  }) async {
    try {
      final orders = await remoteDataSource.getMyOrders(
        status: status,
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(orders);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<OrderEntity>> getOrderDetail(String id) async {
    try {
      final order = await remoteDataSource.getOrderDetail(id);
      return ApiSuccess(order);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> cancelOrder(String id) async {
    try {
      await remoteDataSource.cancelOrder(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
