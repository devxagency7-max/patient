import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';

class PrescriptionModel extends PrescriptionEntity {
  const PrescriptionModel({
    required super.id,
    required super.status,
    super.doctorName,
    super.clinicName,
    super.issueDate,
    super.expiryDate,
    super.imageUrls,
    required super.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      doctorName: json['doctorName'] as String?,
      clinicName: json['clinicName'] as String?,
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
