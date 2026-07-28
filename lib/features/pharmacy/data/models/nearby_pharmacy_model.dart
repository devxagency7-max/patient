import 'package:pharmacare/features/pharmacy/domain/entities/nearby_pharmacy_entity.dart';

class NearbyPharmacyModel extends NearbyPharmacyEntity {
  const NearbyPharmacyModel({
    required super.branchId,
    required super.pharmacyId,
    required super.pharmacyName,
    super.branchName,
    super.address,
    required super.latitude,
    required super.longitude,
    required super.distanceKm,
  });

  factory NearbyPharmacyModel.fromJson(Map<String, dynamic> json) {
    return NearbyPharmacyModel(
      branchId: json['branchId'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      pharmacyName: json['pharmacyName'] as String? ?? '',
      branchName: json['branchName'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
