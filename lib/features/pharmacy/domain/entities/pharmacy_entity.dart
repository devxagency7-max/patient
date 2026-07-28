import 'package:equatable/equatable.dart';

class PharmacyEntity extends Equatable {
  final String id;
  final String name;
  final String? licenseNumber;
  final String? phone;
  final String? email;
  final String status;
  final int branchCount;
  final String? governorate;
  final String? address;
  final String? logoUrl;
  final bool isOpen;
  final String? workingHoursDescription;

  const PharmacyEntity({
    required this.id,
    required this.name,
    this.licenseNumber,
    this.phone,
    this.email,
    required this.status,
    required this.branchCount,
    this.governorate,
    this.address,
    this.logoUrl,
    required this.isOpen,
    this.workingHoursDescription,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        licenseNumber,
        phone,
        email,
        status,
        branchCount,
        governorate,
        address,
        logoUrl,
        isOpen,
        workingHoursDescription,
      ];
}
