import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';

abstract class PatientConditionState extends Equatable {
  const PatientConditionState();

  @override
  List<Object?> get props => [];
}

class PatientConditionInitial extends PatientConditionState {}

class PatientConditionLoading extends PatientConditionState {}

class PatientConditionLoaded extends PatientConditionState {
  final List<PatientConditionEntity> conditions;

  const PatientConditionLoaded(this.conditions);

  @override
  List<Object?> get props => [conditions];
}

class PatientConditionError extends PatientConditionState {
  final String message;

  const PatientConditionError(this.message);

  @override
  List<Object?> get props => [message];
}
