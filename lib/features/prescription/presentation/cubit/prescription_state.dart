import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();

  @override
  List<Object?> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionLoading extends PrescriptionState {}

class PrescriptionSuccess extends PrescriptionState {
  final PrescriptionEntity prescription;

  const PrescriptionSuccess(this.prescription);

  @override
  List<Object?> get props => [prescription];
}

class PrescriptionError extends PrescriptionState {
  final String message;

  const PrescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
