import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressOperationSuccess extends AddressState {
  final String message;

  const AddressOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
