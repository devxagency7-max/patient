import 'package:pharmacare/features/pharmacy/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.pharmacyId,
    required super.pharmacyName,
    super.branchId,
    super.branchName,
    super.finalPrice,
    required super.orderStatus,
    super.deliveryNotes,
    required List<OrderItemModel> super.items,
    required List<OrderStatusHistoryModel> super.statusHistory,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> itemsModels = itemsList.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList();

    var historyList = json['statusHistory'] as List? ?? [];
    List<OrderStatusHistoryModel> historyModels = historyList.map((e) => OrderStatusHistoryModel.fromJson(e as Map<String, dynamic>)).toList();

    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      pharmacyName: json['pharmacyName'] as String? ?? '',
      branchId: json['branchId'] as String?,
      branchName: json['branchName'] as String?,
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      orderStatus: json['orderStatus'] as String? ?? 'Pending',
      deliveryNotes: json['deliveryNotes'] as String?,
      items: itemsModels,
      statusHistory: historyModels,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.medicineId,
    required super.quantity,
    required super.name,
    required super.dosage,
    super.imageUrl,
    super.warnings,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      medicineId: json['medicineId'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      warnings: json['warnings'] as String?,
    );
  }
}

class OrderStatusHistoryModel extends OrderStatusHistoryEntity {
  const OrderStatusHistoryModel({
    required super.id,
    required super.status,
    required super.comments,
    required super.changedByName,
    required super.changedAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id'] as String,
      status: json['status'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      changedByName: json['changedByName'] as String? ?? '',
      changedAt: json['changedAt'] as String? ?? '',
    );
  }
}
