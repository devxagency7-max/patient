import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/medical_records/domain/entities/medical_record_entity.dart';

abstract class MedicalRecordState extends Equatable {
  const MedicalRecordState();

  @override
  List<Object?> get props => [];
}

class MedicalRecordInitial extends MedicalRecordState {}

class MedicalRecordLoading extends MedicalRecordState {}

class MedicalRecordLoaded extends MedicalRecordState {
  final List<MedicalRecordEntity> records;

  const MedicalRecordLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class MedicalRecordSubmitting extends MedicalRecordState {}

class MedicalRecordSubmitSuccess extends MedicalRecordState {}

class MedicalRecordError extends MedicalRecordState {
  final String message;

  const MedicalRecordError(this.message);

  @override
  List<Object?> get props => [message];
}
