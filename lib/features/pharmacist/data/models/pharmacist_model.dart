import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';

class PharmacistModel extends PharmacistEntity {
  const PharmacistModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.activePatientsCount,
    super.maxPatientsLimit,
    required super.isAvailable,
    super.specialization,
    super.averageRating = 0.0,
  });

  factory PharmacistModel.fromJson(Map<String, dynamic> json) {
    return PharmacistModel(
      id: json['id'] as String? ?? json['pharmacistId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['avatarUrl'] as String?,
      activePatientsCount: json['activePatientsCount'] as int? ?? json['totalPatients'] as int? ?? 0,
      maxPatientsLimit: json['maxPatientsLimit'] as int?,
      isAvailable: json['isAvailable'] as bool? ?? json['isAcceptingPatients'] as bool? ?? true,
      specialization: json['specialization'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
