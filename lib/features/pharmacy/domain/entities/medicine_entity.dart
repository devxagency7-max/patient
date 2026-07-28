import 'package:equatable/equatable.dart';

class MedicineEntity extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String? imageUrl;
  final bool requiresPrescription;
  final bool isControlled;
  final String? description;
  final String? warnings;
  final String? activeIngredient;
  final String? form;
  final bool isSensitive;

  const MedicineEntity({
    required this.id,
    required this.name,
    required this.dosage,
    this.imageUrl,
    required this.requiresPrescription,
    required this.isControlled,
    this.description,
    this.warnings,
    this.activeIngredient,
    this.form,
    this.isSensitive = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        imageUrl,
        requiresPrescription,
        isControlled,
        description,
        warnings,
        activeIngredient,
        form,
        isSensitive,
      ];
}
