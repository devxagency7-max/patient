import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.street,
    required super.city,
    required super.governorate,
    super.additionalInfo,
    super.latitude,
    super.longitude,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      governorate: json['governorate'] as String,
      additionalInfo: json['additionalInfo'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'governorate': governorate,
      'additionalInfo': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
