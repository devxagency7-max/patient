import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';

class PatientConditionModel extends PatientConditionEntity {
  const PatientConditionModel({
    required super.id,
    required super.type,
    required super.name,
    super.description,
    super.diagnosedAt,
    required super.createdAt,
  });

  factory PatientConditionModel.fromJson(Map<String, dynamic> json) {
    return PatientConditionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      diagnosedAt:
          json['diagnosedAt'] != null ? DateTime.tryParse(json['diagnosedAt'] as String) : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
