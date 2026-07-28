import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';

abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object?> get props => [];
}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmaciesLoaded extends PharmacyState {
  final List<PharmacyEntity> pharmacies;

  const PharmaciesLoaded(this.pharmacies);

  @override
  List<Object?> get props => [pharmacies];
}

class PharmacyError extends PharmacyState {
  final String message;

  const PharmacyError(this.message);

  @override
  List<Object?> get props => [message];
}
