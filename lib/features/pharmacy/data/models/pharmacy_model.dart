import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  const PharmacyModel({
    required super.id,
    required super.name,
    super.licenseNumber,
    super.phone,
    super.email,
    required super.status,
    required super.branchCount,
    super.governorate,
    super.address,
    super.logoUrl,
    required super.isOpen,
    super.workingHoursDescription,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String? ?? '',
      branchCount: json['branchCount'] as int? ?? 0,
      governorate: json['governorate'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isOpen: json['isOpen'] as bool? ?? false,
      workingHoursDescription: json['workingHoursDescription'] as String?,
    );
  }
}
