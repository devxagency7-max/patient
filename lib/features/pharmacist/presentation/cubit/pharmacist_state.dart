import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';

abstract class PharmacistState extends Equatable {
  const PharmacistState();

  @override
  List<Object?> get props => [];
}

class PharmacistInitial extends PharmacistState {}

class PharmacistLoading extends PharmacistState {}

class PharmacistsLoaded extends PharmacistState {
  final List<PharmacistEntity> pharmacists;

  const PharmacistsLoaded(this.pharmacists);

  @override
  List<Object?> get props => [pharmacists];
}

class PharmacistRequestSuccess extends PharmacistState {}

class PharmacistError extends PharmacistState {
  final String message;

  const PharmacistError(this.message);

  @override
  List<Object?> get props => [message];
}
