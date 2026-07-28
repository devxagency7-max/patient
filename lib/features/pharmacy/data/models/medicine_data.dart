import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

/// عنصر في السلة يعتمد على الـ Entity الحقيقي من السيرفر
class CartItem {
  final MedicineEntity medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});
}
