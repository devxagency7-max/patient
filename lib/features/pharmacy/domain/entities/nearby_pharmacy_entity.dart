import 'package:equatable/equatable.dart';

class NearbyPharmacyEntity extends Equatable {
  final String branchId;
  final String pharmacyId;
  final String pharmacyName;
  final String? branchName;
  final String? address;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const NearbyPharmacyEntity({
    required this.branchId,
    required this.pharmacyId,
    required this.pharmacyName,
    this.branchName,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  @override
  List<Object?> get props => [
        branchId,
        pharmacyId,
        pharmacyName,
        branchName,
        address,
        latitude,
        longitude,
        distanceKm,
      ];
}
