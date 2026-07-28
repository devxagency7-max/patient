import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.id,
    required super.name,
    required super.dosage,
    super.imageUrl,
    required super.requiresPrescription,
    required super.isControlled,
    super.description,
    super.warnings,
    super.activeIngredient,
    super.form,
    super.isSensitive = false,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      requiresPrescription: json['requiresPrescription'] as bool? ?? false,
      isControlled: json['isControlled'] as bool? ?? false,
      description: json['description'] as String?,
      warnings: json['warnings'] as String?,
      activeIngredient: json['activeIngredient'] as String?,
      form: json['form'] as String?,
      isSensitive: json['isSensitive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'imageUrl': imageUrl,
      'requiresPrescription': requiresPrescription,
      'isControlled': isControlled,
      'description': description,
      'warnings': warnings,
      'activeIngredient': activeIngredient,
      'form': form,
      'isSensitive': isSensitive,
    };
  }
}
