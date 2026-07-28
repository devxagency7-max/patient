import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/order_repository.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  /// حارس ضد الإرسال المزدوج — الـ POST /orders غير idempotent، فأي نقرة
  /// مزدوجة أو إعادة استدعاء أثناء التنفيذ يجب ألا تُنشئ طلباً ثانياً.
  bool _isCreatingOrder = false;

  OrderCubit({required this.orderRepository}) : super(OrderInitial());

  Future<void> createOrder({
    required String pharmacyId,
    required String deliveryAddressId,
    String? prescriptionId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  }) async {
    if (_isCreatingOrder) return;
    _isCreatingOrder = true;

    emit(OrderLoading());
    try {
      final result = await orderRepository.createOrder(
        pharmacyId: pharmacyId,
        deliveryAddressId: deliveryAddressId,
        prescriptionId: prescriptionId,
        deliveryNotes: deliveryNotes,
        items: items,
      );

      switch (result) {
        case ApiSuccess(:final data):
          emit(OrderCreatedSuccess(data));
        case ApiFailure(:final failure):
          emit(OrderError(failure.message));
      }
    } finally {
      _isCreatingOrder = false;
    }
  }

  Future<void> fetchMyOrders({String? status, int page = 1, int pageSize = 20}) async {
    emit(OrderLoading());
    final result = await orderRepository.getMyOrders(
      status: status,
      page: page,
      pageSize: pageSize,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(MyOrdersLoaded(data));
      case ApiFailure(:final failure):
        emit(OrderError(failure.message));
    }
  }

  Future<void> fetchOrderDetail(String id) async {
    emit(OrderLoading());
    final result = await orderRepository.getOrderDetail(id);

    switch (result) {
      case ApiSuccess(:final data):
        emit(OrderDetailLoaded(data));
      case ApiFailure(:final failure):
        emit(OrderError(failure.message));
    }
  }

  Future<void> cancelOrder(String id) async {
    emit(OrderLoading());
    final result = await orderRepository.cancelOrder(id);

    switch (result) {
      case ApiSuccess():
        emit(OrderCancelledSuccess());
      case ApiFailure(:final failure):
        emit(OrderError(failure.message));
    }
  }
}
