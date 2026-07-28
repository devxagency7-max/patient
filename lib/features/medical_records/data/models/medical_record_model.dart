import 'package:pharmacare/features/medical_records/domain/entities/medical_record_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  const MedicalRecordModel({
    required super.id,
    required super.fileUrl,
    required super.type,
    super.title,
    super.recordDate,
    super.notes,
    required super.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String?,
      recordDate: json['recordDate'] != null ? DateTime.tryParse(json['recordDate'] as String) : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
