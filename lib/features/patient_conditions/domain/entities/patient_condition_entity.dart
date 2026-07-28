import 'package:equatable/equatable.dart';

class PatientConditionEntity extends Equatable {
  final String id;
  final String type;
  final String name;
  final String? description;
  final DateTime? diagnosedAt;
  final DateTime createdAt;

  const PatientConditionEntity({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.diagnosedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, name, description, diagnosedAt, createdAt];
}
