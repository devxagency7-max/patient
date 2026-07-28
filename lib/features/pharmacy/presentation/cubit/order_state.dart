import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreatedSuccess extends OrderState {
  final OrderEntity order;

  const OrderCreatedSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class MyOrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const MyOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final OrderEntity order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCancelledSuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
