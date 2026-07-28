import 'package:equatable/equatable.dart';

class PharmacyBranchEntity extends Equatable {
  final String id;
  final String pharmacyId;
  final String name;
  final String? address;
  final String? city;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const PharmacyBranchEntity({
    required this.id,
    required this.pharmacyId,
    required this.name,
    this.address,
    this.city,
    this.phone,
    this.latitude,
    this.longitude,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [id, pharmacyId, name, address, city, phone, latitude, longitude, isActive];
}
