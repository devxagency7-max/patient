import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String street;
  final String city;
  final String governorate;
  final String? additionalInfo;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.street,
    required this.city,
    required this.governorate,
    this.additionalInfo,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        id,
        street,
        city,
        governorate,
        additionalInfo,
        latitude,
        longitude,
        isDefault,
      ];
}
