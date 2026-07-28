import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String pharmacyId;
  final String pharmacyName;
  final String? branchId;
  final String? branchName;
  final double? finalPrice;
  final String orderStatus;
  final String? deliveryNotes;
  final List<OrderItemEntity> items;
  final List<OrderStatusHistoryEntity> statusHistory;
  final String createdAt;
  final String? updatedAt;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.pharmacyId,
    required this.pharmacyName,
    this.branchId,
    this.branchName,
    this.finalPrice,
    required this.orderStatus,
    this.deliveryNotes,
    required this.items,
    required this.statusHistory,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        pharmacyId,
        pharmacyName,
        branchId,
        branchName,
        finalPrice,
        orderStatus,
        deliveryNotes,
        items,
        statusHistory,
        createdAt,
        updatedAt,
      ];
}

class OrderItemEntity extends Equatable {
  final String id;
  final String medicineId;
  final int quantity;
  final String name;
  final String dosage;
  final String? imageUrl;
  final String? warnings;

  const OrderItemEntity({
    required this.id,
    required this.medicineId,
    required this.quantity,
    required this.name,
    required this.dosage,
    this.imageUrl,
    this.warnings,
  });

  @override
  List<Object?> get props => [id, medicineId, quantity, name, dosage, imageUrl, warnings];
}

class OrderStatusHistoryEntity extends Equatable {
  final String id;
  final String status;
  final String comments;
  final String changedByName;
  final String changedAt;

  const OrderStatusHistoryEntity({
    required this.id,
    required this.status,
    required this.comments,
    required this.changedByName,
    required this.changedAt,
  });

  @override
  List<Object?> get props => [id, status, comments, changedByName, changedAt];
}
