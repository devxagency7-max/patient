import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';

abstract class MyPrescriptionsState extends Equatable {
  const MyPrescriptionsState();

  @override
  List<Object?> get props => [];
}

class MyPrescriptionsInitial extends MyPrescriptionsState {}

class MyPrescriptionsLoading extends MyPrescriptionsState {}

class MyPrescriptionsLoaded extends MyPrescriptionsState {
  final List<PrescriptionEntity> prescriptions;

  const MyPrescriptionsLoaded(this.prescriptions);

  @override
  List<Object?> get props => [prescriptions];
}

class MyPrescriptionsError extends MyPrescriptionsState {
  final String message;

  const MyPrescriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
