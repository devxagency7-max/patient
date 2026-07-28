import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_branch_entity.dart';

class PharmacyBranchModel extends PharmacyBranchEntity {
  const PharmacyBranchModel({
    required super.id,
    required super.pharmacyId,
    required super.name,
    super.address,
    super.city,
    super.phone,
    super.latitude,
    super.longitude,
    required super.isActive,
  });

  factory PharmacyBranchModel.fromJson(Map<String, dynamic> json) {
    return PharmacyBranchModel(
      id: json['id'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
